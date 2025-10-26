import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/DatabaseInfo.dart';

class DatabaseService {
  DatabaseInfo? _databaseInfo;
  Database? database;

  DatabaseInfo? get databaseInfo => _databaseInfo;

  // Open or create database
  Future<DatabaseInfo> openDB(String name) async {
    final dbPath = join(await getDatabasesPath(), name);

    database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        print('Database created: $name');
      },
    );

    _databaseInfo = DatabaseInfo(name: name, path: dbPath, isOpen: true);
    print('Database opened: $name');
    return _databaseInfo!;
  }

  // Close database
  Future<void> closeDB() async {
    await database?.close();
    print('Database closed: ${_databaseInfo?.name}');
    database = null;
    if (_databaseInfo != null) {
      _databaseInfo = _databaseInfo!.copyWith(isOpen: false);
    }
  }

  // Delete database
  Future<void> deleteDB() async {
    if (_databaseInfo == null) return;

    final dbPath = _databaseInfo!.path;
    if (File(dbPath).existsSync()) {
      await deleteDatabase(dbPath);
      print('Database deleted: ${_databaseInfo!.name}');
    }

    database = null;
    _databaseInfo = null;
  }

  // List all tables
  Future<List<String>> getTables() async {
    if (database == null) return [];
    final result = await database!.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  // Check if database file exists
  Future<bool> databaseExists(String name) async {
    final dbPath = join(await getDatabasesPath(), name);
    return File(dbPath).existsSync();
  }
}
