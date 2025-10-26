import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sql_edit/models/QueryHistory.dart';
import 'package:sql_edit/services/QueryHistory.dart';

final queryHistoryServiceProvider = Provider<QueryHistoryService>((ref) {
  return QueryHistoryService();
});

// Holds list of QueryHistory objects
final queryHistoryProvider = StateProvider<List<QueryHistory>>((ref) {
  final historyService = ref.watch(queryHistoryServiceProvider);
  return historyService.loadHistory();
});
