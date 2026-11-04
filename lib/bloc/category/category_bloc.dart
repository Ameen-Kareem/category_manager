import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/category_repository.dart';
import '../../models/category.dart';
import '../../models/category_node.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;
  final int pageSize = 20;

  CategoryBloc(this.repository) : super(const CategoryState()) {
    on<LoadCategories>(_onLoad);
    on<AddCategory>(_onAdd);
    on<DeleteCategory>(_onDelete);
    on<ToggleCategory>(_onToggle);
    on<SearchCategories>(_onSearch);
  }

  Future<List<CategoryNode>> _loadTree() async {
    final categories = await repository.getAllCategories();
    return buildTree(categories);
  }

  Future<void> _onLoad(LoadCategories event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: ListStatus.loading));
    try {
      final tree = await _loadTree();
      emit(state.copyWith(status: ListStatus.success, tree: tree));
    } catch (e) {
      emit(state.copyWith(status: ListStatus.failure));
    }
  }

  Future<void> _onAdd(AddCategory event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(addStatus: AddStatus.saving));
    try {
      await repository.addCategory(event.name, event.parentId);
      final tree = await _loadTree();

      // open the parent so the new subcategory is visible
      List<int> expanded = List.from(state.expandedIds);
      if (event.parentId != null && !expanded.contains(event.parentId)) {
        expanded.add(event.parentId!);
      }

      emit(state.copyWith(
        tree: tree,
        expandedIds: expanded,
        addStatus: AddStatus.success,
      ));

      // refresh search results if the user is searching
      if (state.query.isNotEmpty) {
        await _runSearch(emit);
      }
    } on DuplicateCategoryException catch (e) {
      emit(state.copyWith(addStatus: AddStatus.failure, addError: e.toString()));
    } catch (e) {
      emit(state.copyWith(
        addStatus: AddStatus.failure,
        addError: 'Could not save the category.',
      ));
    }
  }

  Future<void> _onDelete(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    try {
      await repository.deleteCategory(event.id);
      final tree = await _loadTree();
      emit(state.copyWith(tree: tree));

      if (state.query.isNotEmpty) {
        await _runSearch(emit);
      }
    } catch (e) {
      emit(state.copyWith(message: 'Could not delete the category.'));
      emit(state.copyWith()); // clears the message again
    }
  }

  void _onToggle(ToggleCategory event, Emitter<CategoryState> emit) {
    List<int> expanded = List.from(state.expandedIds);
    if (expanded.contains(event.id)) {
      expanded.remove(event.id);
    } else {
      expanded.add(event.id);
    }
    emit(state.copyWith(expandedIds: expanded));
  }

  Future<void> _onSearch(
      SearchCategories event, Emitter<CategoryState> emit) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        query: '',
        limit: 0,
        page: 1,
        searching: false,
        clearResults: true,
      ));
      return;
    }

    emit(state.copyWith(
      query: event.query,
      limit: event.limit,
      page: event.page,
      searching: true,
    ));
    await _runSearch(emit);
  }

  Future<void> _runSearch(Emitter<CategoryState> emit) async {
    final query = state.query;
    try {
      final result = await repository.searchCategories(
        query,
        page: state.page,
        pageSize: pageSize,
        limit: state.limit > 0 ? state.limit : null,
      );

      // the user may have typed something else while we were waiting
      if (query != state.query) return;

      emit(state.copyWith(results: result, searching: false));
    } catch (e) {
      emit(state.copyWith(searching: false, message: 'Search failed.'));
    }
  }
}
