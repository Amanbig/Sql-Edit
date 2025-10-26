import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseService {
  String dbName = '';
  Database? database; // sqflite Database
  String dbPath = '';

  // Open or create database
  Future<void> openDB(String name) async {
    dbName = name;
    dbPath = join(await getDatabasesPath(), dbName);

    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        print('Database created: $dbName');
      },
    );

    print('Database opened: $dbName');
  }

  // Delete database
  Future<void> deleteDB() async {
    if (dbPath.isNotEmpty) {
      await deleteDatabase(dbPath);
      print('Database deleted: $dbName');
    }

    dbName = '';
    dbPath = '';
    database = null;
  }

  Future<List<String>> getTables() async {
    if (database == null) return [];
    final result = await database!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  Future<bool> databaseExists(String dbName) async {
    final dbPath = join(await getDatabasesPath(), dbName);
    return File(dbPath).existsSync();
  }

  // Close database
  Future<void> closeDB() async {
    await database?.close();
    print('Database closed: $dbName');
    database = null;
  }
}
