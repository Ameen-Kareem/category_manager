import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart';
import '../models/category.dart';

/// [parent] is null when adding a root category.
void showAddCategoryDialog(BuildContext context, Category? parent) {
  showDialog(
    context: context,
    // the dialog is in a new route, so pass the existing bloc to it
    builder: (_) => BlocProvider.value(
      value: context.read<CategoryBloc>(),
      child: AddCategoryDialog(parent: parent),
    ),
  );
}

class AddCategoryDialog extends StatefulWidget {
  final Category? parent;

  const AddCategoryDialog({super.key, this.parent});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _errorFromBloc;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    _errorFromBloc = null;
    if (_formKey.currentState!.validate()) {
      context.read<CategoryBloc>().add(
            AddCategory(_nameController.text.trim(), widget.parent?.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.parent == null
        ? 'Add Category'
        : 'Add subcategory to "${widget.parent!.name}"';

    return BlocConsumer<CategoryBloc, CategoryState>(
      listenWhen: (previous, current) => previous.addStatus != current.addStatus,
      listener: (context, state) {
        if (state.addStatus == AddStatus.success) {
          Navigator.pop(context);
        } else if (state.addStatus == AddStatus.failure) {
          // show the error (for example duplicate name) under the text field
          _errorFromBloc = state.addError;
          _formKey.currentState!.validate();
        }
      },
      buildWhen: (previous, current) => previous.addStatus != current.addStatus,
      builder: (context, state) {
        final isSaving = state.addStatus == AddStatus.saving;

        return AlertDialog(
          title: Text(title),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _nameController,
              autofocus: true,
              enabled: !isSaving,
              decoration: const InputDecoration(labelText: 'Category name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                if (value.trim().length > 50) {
                  return 'Name is too long (max 50 characters)';
                }
                return _errorFromBloc;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
