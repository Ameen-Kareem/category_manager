import 'package:category_manager/models/category.dart';
import 'package:category_manager/models/category_node.dart';
import 'package:flutter_test/flutter_test.dart';

Category makeCategory(int id, String name, int? parentId) {
  return Category(
    id: id,
    name: name,
    parentId: parentId,
    createdAt: DateTime(2024),
  );
}

void main() {
  test('works for a 3 level tree', () {
    final tree = buildTree([
      makeCategory(1, 'A', null),
      makeCategory(2, 'B', 1),
      makeCategory(3, 'C', 2),
    ]);
    expect(getMaxDepth(tree), 3);
  });

  test('works for a 6 level tree', () {
    final tree = buildTree([
      makeCategory(1, 'A', null),
      makeCategory(2, 'B', 1),
      makeCategory(3, 'C', 2),
      makeCategory(4, 'D', 3),
      makeCategory(5, 'E', 4),
      makeCategory(6, 'F', 5),
    ]);
    expect(getMaxDepth(tree), 6);
  });

  test('same name is allowed under different parents', () {
    final tree = buildTree([
      makeCategory(1, 'Electronics', null),
      makeCategory(2, 'Clothing', null),
      makeCategory(3, 'Mobile', 1),
      makeCategory(4, 'Mobile', 2),
    ]);
    expect(findNodes(tree, 'Mobile').length, 2);
  });

  test('finds a deeply nested category', () {
    final tree = buildTree([
      makeCategory(1, 'Electronics', null),
      makeCategory(2, 'Mobile', 1),
      makeCategory(3, 'Android', 2),
      makeCategory(4, 'Samsung', 3),
    ]);
    final found = findNodes(tree, 'Samsung');
    expect(found.length, 1);
    expect(found.first.category.parentId, 3);
  });
}
