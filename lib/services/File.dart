import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sql_edit/models/DatabaseInfo.dart';

class FileService {
  // Export DB
  Future<DatabaseInfo> exportDatabase(String dbName, String destinationPath) async {
    final dbPath = join(await getDatabasesPath(), dbName);
    final file = File(dbPath);
    if (!file.existsSync()) throw Exception("Database does not exist");

    await file.copy(destinationPath);
    return DatabaseInfo(name: dbName, path: destinationPath, isOpen: false);
  }

  // Import DB
  Future<DatabaseInfo> importDatabase(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw Exception("File does not exist");

    final dbPath = join(await getDatabasesPath(), basename(filePath));
    await file.copy(dbPath);
    return DatabaseInfo(name: basename(filePath), path: dbPath, isOpen: false);
  }
}
