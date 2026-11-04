import 'package:flutter/material.dart';

import '../models/category.dart';

/// Shows a category with its parent, children and full path.
class CategoryDetailView extends StatelessWidget {
  final CategoryDetail detail;

  const CategoryDetailView({super.key, required this.detail});

  // Builds text like:
  // Electronics
  // └── Mobile
  //     └── Android
  String _buildTreeText() {
    String text = '';
    for (int i = 0; i < detail.path.length; i++) {
      if (i == 0) {
        text += '${detail.path[i].name}\n';
      } else {
        String indent = '    ' * (i - 1);
        text += '$indent└── ${detail.path[i].name}\n';
      }
    }
    return text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final pathText = detail.path.map((c) => c.name).join(' > ');
    final childrenText = detail.children.isEmpty
        ? 'None'
        : detail.children.map((c) => c.name).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          detail.category.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Parent: ${detail.parent?.name ?? 'None (root category)'}'),
        Text('Subcategories: $childrenText'),
        Text('Path: $pathText'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade200,
          child: Text(
            _buildTreeText(),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
