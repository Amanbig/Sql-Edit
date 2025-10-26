import 'package:sqflite/sqflite.dart';
import 'package:sql_edit/models/QueryResult.dart';

class QueryService {
  final Database? db;

  QueryService(this.db);

  Future<QueryResult> runSelect(String sql) async {
    if (db == null) throw Exception("Database not opened");

    final executedAt = DateTime.now();
    final rows = await db!.rawQuery(sql);

    final columns = rows.isNotEmpty
        ? rows.first.keys.map((key) => key.toString()).toList().cast<String>()
        : <String>[];

    return QueryResult(columns: columns, rows: rows, executedAt: executedAt);
  }

  Future<QueryResult> executeNonQuery(String sql) async {
    if (db == null) throw Exception("Database not opened");

    await db!.execute(sql);
    return QueryResult(columns: [], rows: [], executedAt: DateTime.now());
  }

  Future<QueryResult> runQuery(String sql) async {
    final trimmedSql = sql.trim();
    final upperSql = trimmedSql.toUpperCase();
    if (upperSql.startsWith("SELECT")) return runSelect(trimmedSql);
    return executeNonQuery(trimmedSql);
  }
}
