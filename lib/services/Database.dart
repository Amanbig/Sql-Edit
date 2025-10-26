import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  // Close database
  Future<void> closeDB() async {
    await database?.close();
    print('Database closed: $dbName');
    database = null;
  }
}
