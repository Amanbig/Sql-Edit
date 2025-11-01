import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sql_edit/models/DatabaseInfo.dart';
import 'package:sql_edit/services/Database.dart';

// Singleton instance of DatabaseService
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Holds current DatabaseInfo (open database)
final databaseInfoProvider = StateProvider<DatabaseInfo?>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.databaseInfo;
});
