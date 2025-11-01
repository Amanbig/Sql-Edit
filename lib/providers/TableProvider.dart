import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sql_edit/providers/DatabaseServiceProvider.dart';

// Provider for current table list
final tableListProvider = StateProvider<List<String>>((ref) => []);

// Provider for selected table
final selectedTableProvider = StateProvider<String?>((ref) => null);

// Provider for table data
final tableDataProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

// Provider for table columns
final tableColumnsProvider = StateProvider<List<String>>((ref) => []);

// Provider for table schema
final tableSchemaProvider = StateProvider<List<Map<String, dynamic>>>(
  (ref) => [],
);

// Provider for refreshing tables
final tableRefreshProvider = FutureProvider<List<String>>((ref) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getTables();
});

// Provider for table service
final tableServiceProvider = Provider<TableService>((ref) {
  return TableService(ref.read(databaseServiceProvider));
});

class TableService {
  final dynamic _databaseService;

  TableService(this._databaseService);

  Future<List<String>> refreshTables() async {
    return await _databaseService.getTables();
  }

  Future<List<Map<String, dynamic>>> getTableData(
    String tableName, {
    int limit = 100,
  }) async {
    if (_databaseService.database == null) return [];

    final result = await _databaseService.database!.rawQuery(
      'SELECT * FROM $tableName LIMIT ?',
      [limit],
    );

    return result;
  }

  Future<List<String>> getTableColumns(String tableName) async {
    if (_databaseService.database == null) return [];

    final result = await _databaseService.database!.rawQuery(
      'PRAGMA table_info($tableName)',
    );

    return result.map((row) => row['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getTableSchema(String tableName) async {
    if (_databaseService.database == null) return [];

    final result = await _databaseService.database!.rawQuery(
      'PRAGMA table_info($tableName)',
    );

    return result;
  }

  Future<int> getTableRowCount(String tableName) async {
    if (_databaseService.database == null) return 0;

    final result = await _databaseService.database!.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName',
    );

    return result.first['count'] as int;
  }

  Future<void> dropTable(String tableName) async {
    if (_databaseService.database == null) return;

    await _databaseService.database!.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<void> createTable(
    String tableName,
    List<Map<String, String>> columns,
  ) async {
    if (_databaseService.database == null) return;

    final columnDefinitions = columns.map((col) {
      return '${col['name']} ${col['type']}${col['constraints'] ?? ''}';
    }).join(', ');

    final sql = 'CREATE TABLE $tableName ($columnDefinitions)';
    await _databaseService.database!.execute(sql);
  }

  Future<void> insertSampleData(String tableName) async {
    if (_databaseService.database == null) return;

    // This is a basic implementation - in a real app, you'd want more sophisticated sample data
    final columns = await getTableColumns(tableName);
    if (columns.isEmpty) return;

    final placeholders = List.filled(columns.length, '?').join(', ');
    final sampleValues = columns.map((col) => 'Sample $col').toList();

    await _databaseService.database!.rawInsert(
      'INSERT INTO $tableName (${columns.join(', ')}) VALUES ($placeholders)',
      sampleValues,
    );
  }
}
