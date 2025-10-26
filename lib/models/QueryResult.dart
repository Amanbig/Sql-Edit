class QueryResult {
  final List<String> columns;
  final List<Map<String, dynamic>> rows;
  final DateTime executedAt;

  QueryResult({
    required this.columns,
    required this.rows,
    required this.executedAt,
  });

  QueryResult copyWith({
    List<String>? columns,
    List<Map<String, dynamic>>? rows,
    DateTime? executedAt,
  }) {
    return QueryResult(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      executedAt: executedAt ?? this.executedAt,
    );
  }
}
