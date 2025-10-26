import 'package:code_text_field/code_text_field.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/sql.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sql_edit/providers/DatabaseServiceProvider.dart';
import 'package:sql_edit/providers/QueryHistoryProvider.dart';
import 'package:sql_edit/providers/QueryServiceProvider.dart';
import 'package:sql_edit/providers/TableProvider.dart';

class SqlEditorScreen extends ConsumerStatefulWidget {
  const SqlEditorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SqlEditorScreen> createState() => _SqlEditorScreenState();
}

class _SqlEditorScreenState extends ConsumerState<SqlEditorScreen> {
  late CodeController _queryController;

  @override
  void initState() {
    super.initState();
    _queryController = CodeController(
      text: 'SELECT * FROM table_name;',
      language: sql,
    );
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbInfo = ref.watch(databaseInfoProvider);
    final queryResult = ref.watch(queryResultProvider);
    final history = ref.watch(queryHistoryProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dbInfo != null ? "DB: ${dbInfo.name}" : "No Database",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/database-manager'),
            icon: const Icon(Icons.storage),
            tooltip: 'Database Manager',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: dbInfo != null ? Colors.greenAccent : Colors.redAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  dbInfo != null ? "Connected" : "Disconnected",
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Database Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles();

                    if (result != null) {
                      final dbService = ref.read(databaseServiceProvider);
                      final info = await dbService.openDB(
                        result.files.single.path!,
                      );
                      ref.read(databaseInfoProvider.notifier).state = info;
                      _showSnackbar("Database opened: ${info.name}");
                    } else {
                      _showSnackbar("File picking canceled");
                    }
                  },
                  icon: const Icon(Icons.folder_open),
                  label: const Text("Open DB"),
                ),
                ElevatedButton.icon(
                  onPressed: dbInfo != null
                      ? () async {
                          final dbService = ref.read(databaseServiceProvider);
                          await dbService.closeDB();
                          ref.read(databaseInfoProvider.notifier).state = null;
                          ref.read(queryResultProvider.notifier).state = null;
                          ref.read(tableListProvider.notifier).state = [];
                          ref.read(selectedTableProvider.notifier).state = null;
                          _showSnackbar("Database closed");
                        }
                      : null,
                  icon: const Icon(Icons.close),
                  label: const Text("Close DB"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _queryController.clear();
                    _showSnackbar("Query cleared");
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text("Clear Query"),
                ),
                ElevatedButton.icon(
                  onPressed: queryResult != null ? _shareResult : null,
                  icon: const Icon(Icons.share),
                  label: const Text("Share Result"),
                ),
                ElevatedButton.icon(
                  onPressed: dbInfo != null ? _refreshTables : null,
                  icon: const Icon(Icons.table_chart),
                  label: const Text("View Tables"),
                ),
              ],
            ),
          ),

          // Query Editor
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CodeField(
                controller: _queryController,
                textStyle: GoogleFonts.sourceCodePro(),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // Execute Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: dbInfo != null ? _executeQuery : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text("Execute Query"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),

          // Main Content: Results + History
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Query Results
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.table_chart),
                          title: Text("Query Results"),
                        ),
                        Expanded(
                          child:
                              queryResult != null && queryResult.rows.isNotEmpty
                              ? DataTable2(
                                  columns: queryResult.columns
                                      .map(
                                        (col) => DataColumn2(
                                          label: Text(col),
                                          size: ColumnSize.L,
                                        ),
                                      )
                                      .toList(),
                                  rows: queryResult.rows
                                      .map(
                                        (row) => DataRow2(
                                          cells: queryResult.columns
                                              .map(
                                                (col) => DataCell(
                                                  Text(
                                                    row[col]?.toString() ?? "",
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      )
                                      .toList(),
                                )
                              : const Center(
                                  child: Text("No results to display"),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Query History
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const ListTile(
                          leading: Icon(Icons.history),
                          title: Text("Query History"),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (_, index) {
                              final q = history[index];
                              return ListTile(
                                title: Text(
                                  q.query,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(q.executedAt.toString()),
                                onTap: () {
                                  _queryController.text = q.query;
                                  _showSnackbar("Loaded query from history");
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _executeQuery() async {
    final queryService = ref.read(queryServiceProvider);
    final historyService = ref.read(queryHistoryServiceProvider);

    try {
      final result = await queryService.runQuery(_queryController.text);
      ref.read(queryResultProvider.notifier).state = result;

      historyService.saveQuery(_queryController.text);
      ref.read(queryHistoryProvider.notifier).state = historyService
          .loadHistory();

      _showSnackbar("Query executed successfully (${result.rows.length} rows)");
    } catch (e) {
      _showSnackbar("Error: ${e.toString()}", isError: true);
    }
  }

  void _shareResult() {
    final queryResult = ref.read(queryResultProvider);
    if (queryResult == null) return;

    final buffer = StringBuffer();
    buffer.writeln(queryResult.columns.join(","));
    for (final row in queryResult.rows) {
      buffer.writeln(
        queryResult.columns.map((col) => row[col]?.toString() ?? "").join(","),
      );
    }

    Share.share(buffer.toString(), subject: "SQL Query Result");
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  void _refreshTables() async {
    try {
      final tableService = ref.read(tableServiceProvider);
      final tables = await tableService.refreshTables();
      ref.read(tableListProvider.notifier).state = tables;
      _showSnackbar("Tables refreshed: ${tables.length} tables found");
    } catch (e) {
      _showSnackbar("Error refreshing tables: $e");
    }
  }
}
