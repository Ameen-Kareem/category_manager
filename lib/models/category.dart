class Category {
  final int id;
  final String name;
  final int? parentId;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      parentId: map['parent_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

/// A category together with its parent, children and full path.
class CategoryDetail {
  final Category category;
  final Category? parent;
  final List<Category> children;
  final List<Category> path; // root -> ... -> this category

  CategoryDetail({
    required this.category,
    required this.parent,
    required this.children,
    required this.path,
  });
}

class DuplicateCategoryException implements Exception {
  final String name;
  DuplicateCategoryException(this.name);

  @override
  String toString() => '"$name" already exists under this parent.';
}
