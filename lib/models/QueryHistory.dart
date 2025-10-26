class QueryHistory {
  final String query;
  final DateTime executedAt;

  QueryHistory({
    required this.query,
    required this.executedAt,
  });

  QueryHistory copyWith({
    String? query,
    DateTime? executedAt,
  }) {
    return QueryHistory(
      query: query ?? this.query,
      executedAt: executedAt ?? this.executedAt,
    );
  }
}
