import 'category.dart';

/// Node used to show the categories as a tree.
class CategoryNode {
  final Category category;
  final List<CategoryNode> children = [];

  CategoryNode(this.category);
}

/// Turns the flat list from the database into a tree.
/// It does not care how deep the tree is.
List<CategoryNode> buildTree(List<Category> categories) {
  Map<int, CategoryNode> nodeMap = {};
  for (var category in categories) {
    nodeMap[category.id] = CategoryNode(category);
  }

  List<CategoryNode> roots = [];
  for (var category in categories) {
    CategoryNode node = nodeMap[category.id]!;
    if (category.parentId == null) {
      roots.add(node);
    } else {
      nodeMap[category.parentId]?.children.add(node);
    }
  }
  return roots;
}

/// Recursively finds the depth of the tree.
int getMaxDepth(List<CategoryNode> nodes) {
  int maxDepth = 0;
  for (var node in nodes) {
    int depth = 1 + getMaxDepth(node.children);
    if (depth > maxDepth) {
      maxDepth = depth;
    }
  }
  return maxDepth;
}

/// Recursively finds every node whose name contains [query].
List<CategoryNode> findNodes(List<CategoryNode> nodes, String query) {
  List<CategoryNode> found = [];
  for (var node in nodes) {
    if (node.category.name.toLowerCase().contains(query.toLowerCase())) {
      found.add(node);
    }
    found.addAll(findNodes(node.children, query));
  }
  return found;
}
