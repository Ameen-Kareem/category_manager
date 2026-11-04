import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart';
import '../models/category_node.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/category_detail_view.dart';
import '../widgets/category_tile.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _searchController = TextEditingController();
  final _limitController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _search(int page) {
    final limit = int.tryParse(_limitController.text.trim()) ?? 0;
    context.read<CategoryBloc>().add(SearchCategories(
          query: _searchController.text.trim(),
          limit: limit,
          page: page,
        ));
  }

  /// Recursive: adds a node, and if it is expanded, adds its children too.
  List<TreeRow> _getRows(
      List<CategoryNode> nodes, List<int> expandedIds, int level) {
    List<TreeRow> rows = [];
    for (var node in nodes) {
      bool isExpanded = expandedIds.contains(node.category.id);
      rows.add(TreeRow(node, level, isExpanded));
      if (isExpanded) {
        rows.addAll(_getRows(node.children, expandedIds, level + 1));
      }
    }
    return rows;
  }

  Widget _buildTree(CategoryState state) {
    if (state.tree.isEmpty) {
      return const Center(
        child: Text(
          'No categories yet.\nTap "Add Category" to create one.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final rows = _getRows(state.tree, state.expandedIds, 0);
    return ListView.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) => CategoryTile(row: rows[index]),
    );
  }

  Widget _buildSearchResults(CategoryState state) {
    final results = state.results;

    if (results == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.totalCount == 0) {
      return Center(child: Text('No categories found for "${state.query}"'));
    }

    return Column(
      children: [
        if (state.searching) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            'Page ${results.page} of ${results.totalPages} | '
            'Page size: ${results.pageSize} | '
            'Total: ${results.totalCount}',
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.items.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: CategoryDetailView(detail: results.items[index]),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: results.hasPrevious ? () => _search(results.page - 1) : null,
            ),
            Text('${results.page} / ${results.totalPages}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: results.hasNext ? () => _search(results.page + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(CategoryState state) {
    if (state.status == ListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ListStatus.failure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load categories.'),
            TextButton(
              onPressed: () => context.read<CategoryBloc>().add(LoadCategories()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state.query.isNotEmpty) {
      return _buildSearchResults(state);
    }
    return _buildTree(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listenWhen: (previous, current) => current.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message!)));
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Categories')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _search(1),
                      decoration: const InputDecoration(
                        hintText: 'Search categories...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _limitController,
                      onChanged: (value) => _search(1),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Limit',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Category'),
                  onPressed: () => showAddCategoryDialog(context, null),
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) => _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
