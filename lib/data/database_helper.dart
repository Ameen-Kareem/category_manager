import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'categories.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // needed so deleting a category also deletes its subcategories
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            parent_id INTEGER,
            created_at TEXT NOT NULL,
            FOREIGN KEY (parent_id) REFERENCES categories (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('CREATE INDEX idx_parent ON categories (parent_id)');
        await db.execute('CREATE INDEX idx_name ON categories (name)');
      },
    );
  }
}
