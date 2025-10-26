import 'package:sql_edit/models/QueryHistory.dart';

class QueryHistoryService {
  final List<QueryHistory> _history = [];

  void saveQuery(String sql) {
    _history.add(QueryHistory(query: sql, executedAt: DateTime.now()));
  }

  List<QueryHistory> loadHistory() => _history.reversed.toList();

  void deleteQuery(QueryHistory item) => _history.remove(item);

  void clearHistory() => _history.clear();
}
