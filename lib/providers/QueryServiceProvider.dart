import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sql_edit/models/QueryResult.dart';
import 'package:sql_edit/providers/DatabaseServiceProvider.dart';
import 'package:sql_edit/services/Query.dart';

// Provider that depends on DatabaseService
final queryServiceProvider = Provider<QueryService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return QueryService(dbService.database);
});

// Holds last executed query result
final queryResultProvider = StateProvider<QueryResult?>((ref) {
  return null; // initial state
});
