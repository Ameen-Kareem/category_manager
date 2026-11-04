class PageResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;

  PageResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
  });

  int get totalPages {
    if (totalCount == 0) return 1;
    return (totalCount / pageSize).ceil();
  }

  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;

  Map<String, int> toMap() {
    return {'page': page, 'page_size': pageSize, 'total_count': totalCount};
  }
}
