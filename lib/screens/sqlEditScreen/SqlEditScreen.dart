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

class _SqlEditorScreenState extends ConsumerState<SqlEditorScreen>
    with TickerProviderStateMixin {
  late CodeController _queryController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _queryController = CodeController(
      text:
          '-- Welcome to SQL Editor\n-- Write your SQL queries here\n\nSELECT * FROM table_name LIMIT 10;',
      language: sql,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dbInfo = ref.watch(databaseInfoProvider);
    final queryResult = ref.watch(queryResultProvider);
    final history = ref.watch(queryHistoryProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.code_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SQL Editor",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dbInfo != null
                      ? "Connected to ${dbInfo.name}"
                      : "No database connected",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/database-manager'),
                  icon: Icon(
                    Icons.storage_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: 'Database Manager',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: theme.colorScheme.outline.withOpacity(0.3),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: dbInfo != null
                              ? Colors.green
                              : theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dbInfo != null ? "Connected" : "Disconnected",
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Enhanced Database Controls
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Database Controls",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isLargeScreen)
                        Row(
                          children: _buildControlButtons(
                            theme,
                            dbInfo,
                            queryResult,
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: _buildControlButtons(
                            theme,
                            dbInfo,
                            queryResult,
                          ),
                        ),
                    ],
                  ),
                ),

                // Enhanced Query Editor
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Query Editor",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "SQL",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: CodeField(
                              controller: _queryController,
                              textStyle: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                height: 1.4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Enhanced Execute Button
                Container(
                  margin: const EdgeInsets.all(16),
                  child: FilledButton.icon(
                    onPressed: dbInfo != null ? _executeQuery : null,
                    icon: Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(
                      "Execute Query",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Enhanced Main Content: Results + History
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: isLargeScreen
                        ? Row(
                            children: [
                              _buildResultsPanel(context, theme, queryResult),
                              const SizedBox(width: 16),
                              _buildHistoryPanel(context, theme, history),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildResultsPanel(
                                  context,
                                  theme,
                                  queryResult,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                flex: 1,
                                child: _buildHistoryPanel(
                                  context,
                                  theme,
                                  history,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildControlButtons(
    ThemeData theme,
    dynamic dbInfo,
    dynamic queryResult,
  ) {
    return [
      FilledButton.icon(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles();
          if (result != null && result.files.single.path != null) {
            final dbService = ref.read(databaseServiceProvider);
            final info = await dbService.openDB(result.files.single.path!);
            ref.read(databaseInfoProvider.notifier).state = info;
            _showSnackbar("Database opened: ${info.name}");
          } else {
            _showSnackbar("File picking canceled");
          }
        },
        icon: const Icon(Icons.folder_open_rounded, size: 18),
        label: const Text("Open DB"),
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      OutlinedButton.icon(
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
        icon: const Icon(Icons.close_rounded, size: 18),
        label: const Text("Close DB"),
      ),
      OutlinedButton.icon(
        onPressed: () {
          _queryController.text = '-- Write your SQL query here\n\n';
          _queryController.selection = TextSelection.fromPosition(
            TextPosition(offset: _queryController.text.length),
          );
          _showSnackbar("Query editor cleared");
        },
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text("Clear"),
      ),
      OutlinedButton.icon(
        onPressed: queryResult != null ? _shareResult : null,
        icon: const Icon(Icons.share_rounded, size: 18),
        label: const Text("Share"),
      ),
      OutlinedButton.icon(
        onPressed: dbInfo != null ? _refreshTables : null,
        icon: const Icon(Icons.table_chart_rounded, size: 18),
        label: const Text("Tables"),
      ),
    ];
  }

  Widget _buildResultsPanel(
    BuildContext context,
    ThemeData theme,
    dynamic queryResult,
  ) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.table_chart_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Query Results",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (queryResult != null && queryResult.rows.isNotEmpty) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${queryResult.rows.length} rows",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            Expanded(
              child: queryResult != null && queryResult.rows.isNotEmpty
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable2(
                          columnSpacing: 16,
                          horizontalMargin: 20,
                          minWidth: 600,
                          headingRowColor: MaterialStateProperty.all(
                            theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          ),
                          columns: queryResult.columns
                              .map(
                                (col) => DataColumn2(
                                  label: Text(
                                    col,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_chart_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No results to display",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Execute a query to see results here",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPanel(
    BuildContext context,
    ThemeData theme,
    List<dynamic> history,
  ) {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.history_rounded,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Query History",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (history.isNotEmpty) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${history.length}",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
            Expanded(
              child: history.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: history.length,
                      itemBuilder: (_, index) {
                        final q = history[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: theme.colorScheme.surfaceVariant
                                .withOpacity(0.3),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.code_rounded,
                                color: theme.colorScheme.secondary,
                                size: 16,
                              ),
                            ),
                            title: Text(
                              q.query,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily:
                                    GoogleFonts.jetBrainsMono().fontFamily,
                              ),
                            ),
                            subtitle: Text(
                              q.executedAt.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                            onTap: () {
                              _queryController.text = q.query;
                              _showSnackbar("Loaded query from history");
                            },
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No query history",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your executed queries will appear here",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
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
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
