import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sql_edit/services/File.dart';

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});
