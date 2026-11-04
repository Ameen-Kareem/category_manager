import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {}

// parentId == null means a root category, otherwise it is a subcategory
class AddCategory extends CategoryEvent {
  final String name;
  final int? parentId;
  AddCategory(this.name, this.parentId);

  @override
  List<Object?> get props => [name, parentId];
}

class DeleteCategory extends CategoryEvent {
  final int id;
  DeleteCategory(this.id);

  @override
  List<Object?> get props => [id];
}

// expand / collapse
class ToggleCategory extends CategoryEvent {
  final int id;
  ToggleCategory(this.id);

  @override
  List<Object?> get props => [id];
}

// empty query = go back to the tree. limit 0 = no limit
class SearchCategories extends CategoryEvent {
  final String query;
  final int limit;
  final int page;
  SearchCategories({required this.query, this.limit = 0, this.page = 1});

  @override
  List<Object?> get props => [query, limit, page];
}
