import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../data/category_repository.dart';
import '../models/category_node.dart';
import 'add_category_dialog.dart';
import 'category_detail_view.dart';

/// One visible line of the tree.
class TreeRow {
  final CategoryNode node;
  final int level;
  final bool isExpanded;

  TreeRow(this.node, this.level, this.isExpanded);
}

class CategoryTile extends StatelessWidget {
  final TreeRow row;

  const CategoryTile({super.key, required this.row});

  Future<void> _showDetails(BuildContext context) async {
    final repository = context.read<CategoryRepository>();
    final detail = await repository.getDetail(row.node.category.id);
    if (detail == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SingleChildScrollView(
          child: CategoryDetailView(detail: detail),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final category = row.node.category;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete category'),
        content: Text(
          'Delete "${category.name}" and all of its subcategories?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CategoryBloc>().add(DeleteCategory(category.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = row.node.category;
    final hasChildren = row.node.children.isNotEmpty;

    return InkWell(
      onTap: hasChildren
          ? () => context.read<CategoryBloc>().add(ToggleCategory(category.id))
          : null,
      child: Padding(
        padding: EdgeInsets.only(left: 8.0 + row.level * 20, right: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: hasChildren
                  ? Icon(row.isExpanded ? Icons.expand_more : Icons.chevron_right)
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(category.name),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'add') {
                  showAddCategoryDialog(context, category);
                } else if (value == 'details') {
                  _showDetails(context);
                } else if (value == 'delete') {
                  _confirmDelete(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'add', child: Text('Add subcategory')),
                PopupMenuItem(value: 'details', child: Text('Details')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
