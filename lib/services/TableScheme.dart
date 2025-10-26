import 'package:sqflite/sqflite.dart';
import 'package:sql_edit/models/ColumnInfo.dart';

class TableSchemaService {
  final Database? db;

  TableSchemaService(this.db);

  Future<List<ColumnInfo>> getTableSchema(String tableName) async {
    if (db == null) return [];
    final result = await db!.rawQuery('PRAGMA table_info($tableName);');

    return result.map((row) {
      return ColumnInfo(
        name: row['name'] as String,
        type: row['type'] as String,
        isPrimaryKey: (row['pk'] as int) == 1,
        isNullable: (row['notnull'] as int) == 0,
      );
    }).toList();
  }
}
