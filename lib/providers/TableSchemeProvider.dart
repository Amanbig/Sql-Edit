import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sql_edit/models/ColumnInfo.dart';
import 'package:sql_edit/providers/DatabaseServiceProvider.dart';
import 'package:sql_edit/services/TableScheme.dart';

final tableSchemaServiceProvider = Provider<TableSchemaService>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return TableSchemaService(dbService.database);
});

// Holds schema for a selected table
final tableSchemaProvider = StateProvider<List<ColumnInfo>>((ref) => []);
