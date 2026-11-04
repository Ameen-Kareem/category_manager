import 'package:sqflite/sqflite.dart';

import '../models/category.dart';
import '../models/page_result.dart';
import 'database_helper.dart';

class CategoryRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Category> addCategory(String name, int? parentId) async {
    final db = await _dbHelper.database;
    name = name.trim();

    // name must be unique inside the same parent
    List<Map<String, dynamic>> existing;
    if (parentId == null) {
      existing = await db.query(
        'categories',
        where: 'parent_id IS NULL AND LOWER(name) = ?',
        whereArgs: [name.toLowerCase()],
      );
    } else {
      existing = await db.query(
        'categories',
        where: 'parent_id = ? AND LOWER(name) = ?',
        whereArgs: [parentId, name.toLowerCase()],
      );
    }
    if (existing.isNotEmpty) {
      throw DuplicateCategoryException(name);
    }

    final now = DateTime.now();
    final id = await db.insert('categories', {
      'name': name,
      'parent_id': parentId,
      'created_at': now.toIso8601String(),
    });
    return Category(id: id, name: name, parentId: parentId, createdAt: now);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await _dbHelper.database;
    final rows = await db.query('categories', orderBy: 'name COLLATE NOCASE');
    return rows.map((row) => Category.fromMap(row)).toList();
  }

  Future<void> deleteCategory(int id) async {
    final db = await _dbHelper.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<Category?> getCategory(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Category.fromMap(rows.first);
  }

  Future<List<Category>> getChildren(int id) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      'categories',
      where: 'parent_id = ?',
      whereArgs: [id],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map((row) => Category.fromMap(row)).toList();
  }

  /// Recursive: gets the path of the parent first, then adds this category.
  Future<List<Category>> getPath(int id) async {
    final category = await getCategory(id);
    if (category == null) return [];
    if (category.parentId == null) return [category];

    final parentPath = await getPath(category.parentId!);
    return [...parentPath, category];
  }

  Future<CategoryDetail?> getDetail(int id) async {
    final path = await getPath(id);
    if (path.isEmpty) return null;

    final category = path.last;
    Category? parent;
    if (path.length > 1) {
      parent = path[path.length - 2];
    }
    final children = await getChildren(id);

    return CategoryDetail(
      category: category,
      parent: parent,
      children: children,
      path: path,
    );
  }

  /// Searches by name at any depth.
  /// [limit] is optional. If given, at most [limit] results are returned in total.
  Future<PageResult<CategoryDetail>> searchCategories(
    String query, {
    int page = 1,
    int pageSize = 20,
    int? limit,
  }) async {
    final db = await _dbHelper.database;
    final like = '%$query%'; // LIKE is case-insensitive in SQLite

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) FROM categories WHERE name LIKE ?',
      [like],
    );
    int totalCount = Sqflite.firstIntValue(countResult) ?? 0;
    if (limit != null && limit < totalCount) {
      totalCount = limit;
    }

    // how many rows are needed for this page
    int offset = (page - 1) * pageSize;
    int rowsToLoad = totalCount - offset;
    if (rowsToLoad > pageSize) {
      rowsToLoad = pageSize;
    }

    List<CategoryDetail> items = [];
    if (rowsToLoad > 0) {
      final rows = await db.query(
        'categories',
        where: 'name LIKE ?',
        whereArgs: [like],
        orderBy: 'name COLLATE NOCASE',
        limit: rowsToLoad,
        offset: offset,
      );
      for (var row in rows) {
        final detail = await getDetail(row['id'] as int);
        if (detail != null) {
          items.add(detail);
        }
      }
    }

    return PageResult(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
    );
  }
}
