import 'package:equatable/equatable.dart';

import '../../models/category.dart';
import '../../models/category_node.dart';
import '../../models/page_result.dart';

enum ListStatus { loading, success, failure }

enum AddStatus { initial, saving, success, failure }

class CategoryState extends Equatable {
  final ListStatus status;
  final List<CategoryNode> tree;
  final List<int> expandedIds;

  // search
  final String query;
  final int limit; // 0 = no limit
  final int page;
  final PageResult<CategoryDetail>? results;
  final bool searching;

  // add dialog
  final AddStatus addStatus;
  final String? addError;

  // one-time message for a snackbar
  final String? message;

  const CategoryState({
    this.status = ListStatus.loading,
    this.tree = const [],
    this.expandedIds = const [],
    this.query = '',
    this.limit = 0,
    this.page = 1,
    this.results,
    this.searching = false,
    this.addStatus = AddStatus.initial,
    this.addError,
    this.message,
  });

  // Note: addError and message are NOT copied, so they only live for one state.
  CategoryState copyWith({
    ListStatus? status,
    List<CategoryNode>? tree,
    List<int>? expandedIds,
    String? query,
    int? limit,
    int? page,
    PageResult<CategoryDetail>? results,
    bool clearResults = false,
    bool? searching,
    AddStatus? addStatus,
    String? addError,
    String? message,
  }) {
    return CategoryState(
      status: status ?? this.status,
      tree: tree ?? this.tree,
      expandedIds: expandedIds ?? this.expandedIds,
      query: query ?? this.query,
      limit: limit ?? this.limit,
      page: page ?? this.page,
      results: clearResults ? null : (results ?? this.results),
      searching: searching ?? this.searching,
      addStatus: addStatus ?? this.addStatus,
      addError: addError,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        tree,
        expandedIds,
        query,
        limit,
        page,
        results,
        searching,
        addStatus,
        addError,
        message,
      ];
}
