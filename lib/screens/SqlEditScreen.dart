import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sql_edit/providers/DatabaseServiceProvider.dart';
import 'package:sql_edit/providers/QueryHistoryProvider.dart';
import 'package:sql_edit/providers/QueryServiceProvider.dart';

class SqlEditorScreen extends ConsumerStatefulWidget {
  const SqlEditorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SqlEditorScreen> createState() => _SqlEditorScreenState();
}

class _SqlEditorScreenState extends ConsumerState<SqlEditorScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final dbInfo = ref.watch(databaseInfoProvider); // DatabaseInfo?
    final queryResult = ref.watch(queryResultProvider); // QueryResult?
    final history = ref.watch(queryHistoryProvider); // List<QueryHistory>

    return Scaffold(
      appBar: AppBar(
        title: Text(dbInfo != null ? "DB: ${dbInfo.name}" : "No Database"),
      ),
      body: Column(
        children: [
          // Database Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final dbService = ref.read(databaseServiceProvider);
                    final info = await dbService.openDB("my_database.db");
                    ref.read(databaseInfoProvider.notifier).state = info;
                  },
                  child: const Text("Open DB"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: dbInfo != null
                      ? () async {
                          final dbService = ref.read(databaseServiceProvider);
                          await dbService.closeDB();
                          ref.read(databaseInfoProvider.notifier).state = null;
                        }
                      : null,
                  child: const Text("Close DB"),
                ),
              ],
            ),
          ),

          // Query Editor
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _queryController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write SQL query here...",
              ),
            ),
          ),

          // Execute Button
          ElevatedButton(
            onPressed: dbInfo != null
                ? () async {
                    final queryService = ref.read(queryServiceProvider);
                    final historyService = ref.read(queryHistoryServiceProvider);

                    try {
                      final result = await queryService.runQuery(_queryController.text);
                      ref.read(queryResultProvider.notifier).state = result;

                      historyService.saveQuery(_queryController.text);
                      ref.read(queryHistoryProvider.notifier).state =
                          historyService.loadHistory();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  }
                : null,
            child: const Text("Execute Query"),
          ),

          const SizedBox(height: 16),

          // Query Results
          Expanded(
            child: queryResult != null && queryResult.rows.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: queryResult.columns
                          .map((col) => DataColumn(label: Text(col)))
                          .toList(),
                      rows: queryResult.rows
                          .map((row) => DataRow(
                                cells: queryResult.columns
                                    .map((col) => DataCell(
                                          Text(row[col]?.toString() ?? ""),
                                        ))
                                    .toList(),
                              ))
                          .toList(),
                    ),
                  )
                : const Center(child: Text("No results")),
          ),

          // Query History
          Container(
            height: 150,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (_, index) {
                final q = history[index];
                return ListTile(
                  title: Text(q.query),
                  subtitle: Text(q.executedAt.toString()),
                  onTap: () {
                    _queryController.text = q.query;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
