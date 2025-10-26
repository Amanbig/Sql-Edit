import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sql_edit/providers/DatabaseServiceProvider.dart';
import 'package:sql_edit/providers/TableProvider.dart';

class DatabaseManagerScreen extends ConsumerStatefulWidget {
  const DatabaseManagerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DatabaseManagerScreen> createState() =>
      _DatabaseManagerScreenState();
}

class _DatabaseManagerScreenState extends ConsumerState<DatabaseManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _dbNameController = TextEditingController();
  final TextEditingController _tableNameController = TextEditingController();
  final TextEditingController _columnNameController = TextEditingController();
  final TextEditingController _columnTypeController = TextEditingController();

  List<Map<String, String>> _columns = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dbNameController.dispose();
    _tableNameController.dispose();
    _columnNameController.dispose();
    _columnTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dbInfo = ref.watch(databaseInfoProvider);
    final tables = ref.watch(tableListProvider);
    final selectedTable = ref.watch(selectedTableProvider);
    final tableData = ref.watch(tableDataProvider);
    final tableColumns = ref.watch(tableColumnsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Database Manager',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.storage), text: 'Databases'),
            Tab(icon: Icon(Icons.table_chart), text: 'Tables'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDatabaseTab(context, theme, dbInfo),
          _buildTablesTab(
            context,
            theme,
            dbInfo,
            tables,
            selectedTable,
            tableData,
            tableColumns,
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseTab(
    BuildContext context,
    ThemeData theme,
    dynamic dbInfo,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Database Status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Database',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: dbInfo != null ? Colors.green : Colors.red,
                        size: 12,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dbInfo != null ? dbInfo.name : 'No database connected',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                    ],
                  ),
                  if (dbInfo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Path: ${dbInfo.path}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Create New Database
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create New Database',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dbNameController,
                    decoration: InputDecoration(
                      labelText: 'Database Name',
                      hintText: 'Enter database name (e.g., my_app.db)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.storage),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createDatabase,
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Create Database',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Database Actions
          if (dbInfo != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Database Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _refreshTables,
                            icon: const Icon(Icons.refresh),
                            label: Text('Refresh'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _closeDatabase,
                            icon: const Icon(Icons.close),
                            label: Text('Close'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteDatabaseDialog(context),
                        icon: const Icon(Icons.delete),
                        label: Text('Delete Database'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTablesTab(
    BuildContext context,
    ThemeData theme,
    dynamic dbInfo,
    List<String> tables,
    String? selectedTable,
    List<Map<String, dynamic>> tableData,
    List<String> tableColumns,
  ) {
    if (dbInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storage_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No Database Connected',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please connect to a database first',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Tables List
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.table_chart),
                  title: Text(
                    'Tables (${tables.length})',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    onPressed: _refreshTables,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: tables.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.table_chart_outlined,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No tables found',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: tables.length,
                          itemBuilder: (context, index) {
                            final tableName = tables[index];
                            final isSelected = selectedTable == tableName;
                            return ListTile(
                              selected: isSelected,
                              leading: Icon(
                                Icons.table_view,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              title: Text(tableName),
                              onTap: () => _selectTable(tableName),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(Icons.info, size: 16),
                                        SizedBox(width: 8),
                                        Text('View Schema'),
                                      ],
                                    ),
                                    onTap: () => _viewTableSchema(tableName),
                                  ),
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Drop Table',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showDropTableDialog(
                                      context,
                                      tableName,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showCreateTableDialog(context),
                      icon: const Icon(Icons.add),
                      label: Text('Create Table'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Table Data
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.view_list),
                  title: Text(
                    selectedTable != null
                        ? 'Data: $selectedTable'
                        : 'Select a table',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  trailing: selectedTable != null
                      ? ElevatedButton.icon(
                          onPressed: () => _loadTableData(selectedTable),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        )
                      : null,
                ),
                const Divider(height: 1),
                Expanded(
                  child: selectedTable == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Select a table to view its data',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : tableData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 48,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No data in this table',
                                style: GoogleFonts.poppins(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: DataTable(
                              columns: tableColumns
                                  .map((col) => DataColumn(label: Text(col)))
                                  .toList(),
                              rows: tableData
                                  .map(
                                    (row) => DataRow(
                                      cells: tableColumns
                                          .map(
                                            (col) => DataCell(
                                              Text(row[col]?.toString() ?? ''),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _createDatabase() async {
    if (_dbNameController.text.isEmpty) {
      _showSnackbar('Please enter a database name');
      return;
    }

    try {
      final dbService = ref.read(databaseServiceProvider);
      String dbName = _dbNameController.text;
      if (!dbName.endsWith('.db')) {
        dbName += '.db';
      }

      final info = await dbService.openDB(dbName);
      ref.read(databaseInfoProvider.notifier).state = info;
      _dbNameController.clear();
      _showSnackbar('Database created successfully: $dbName');
      _refreshTables();
    } catch (e) {
      _showSnackbar('Error creating database: $e');
    }
  }

  void _closeDatabase() async {
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.closeDB();
      ref.read(databaseInfoProvider.notifier).state = null;
      ref.read(tableListProvider.notifier).state = [];
      ref.read(selectedTableProvider.notifier).state = null;
      ref.read(tableDataProvider.notifier).state = [];
      _showSnackbar('Database closed');
    } catch (e) {
      _showSnackbar('Error closing database: $e');
    }
  }

  void _refreshTables() async {
    try {
      final tableService = ref.read(tableServiceProvider);
      final tables = await tableService.refreshTables();
      ref.read(tableListProvider.notifier).state = tables;
    } catch (e) {
      _showSnackbar('Error refreshing tables: $e');
    }
  }

  void _selectTable(String tableName) {
    ref.read(selectedTableProvider.notifier).state = tableName;
    _loadTableData(tableName);
  }

  void _loadTableData(String tableName) async {
    try {
      final tableService = ref.read(tableServiceProvider);
      final data = await tableService.getTableData(tableName);
      final columns = await tableService.getTableColumns(tableName);

      ref.read(tableDataProvider.notifier).state = data;
      ref.read(tableColumnsProvider.notifier).state = columns;
    } catch (e) {
      _showSnackbar('Error loading table data: $e');
    }
  }

  void _viewTableSchema(String tableName) async {
    try {
      final tableService = ref.read(tableServiceProvider);
      final schema = await tableService.getTableSchema(tableName);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Schema: $tableName'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Column')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Not Null')),
                  DataColumn(label: Text('Default')),
                  DataColumn(label: Text('Primary Key')),
                ],
                rows: schema
                    .map(
                      (col) => DataRow(
                        cells: [
                          DataCell(Text(col['name']?.toString() ?? '')),
                          DataCell(Text(col['type']?.toString() ?? '')),
                          DataCell(Text(col['notnull']?.toString() ?? '')),
                          DataCell(Text(col['dflt_value']?.toString() ?? '')),
                          DataCell(Text(col['pk']?.toString() ?? '')),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackbar('Error viewing schema: $e');
    }
  }

  void _showCreateTableDialog(BuildContext context) {
    _columns.clear();
    _tableNameController.clear();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Create Table'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                TextField(
                  controller: _tableNameController,
                  decoration: InputDecoration(
                    labelText: 'Table Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _columnNameController,
                        decoration: InputDecoration(
                          labelText: 'Column Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _columnTypeController,
                        decoration: InputDecoration(
                          labelText: 'Type (e.g., TEXT, INTEGER)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_columnNameController.text.isNotEmpty &&
                            _columnTypeController.text.isNotEmpty) {
                          setState(() {
                            _columns.add({
                              'name': _columnNameController.text,
                              'type': _columnTypeController.text,
                            });
                          });
                          _columnNameController.clear();
                          _columnTypeController.clear();
                        }
                      },
                      child: Text('Add'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _columns.length,
                    itemBuilder: (context, index) {
                      final column = _columns[index];
                      return ListTile(
                        title: Text('${column['name']} (${column['type']})'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _columns.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_tableNameController.text.isNotEmpty &&
                    _columns.isNotEmpty) {
                  try {
                    final tableService = ref.read(tableServiceProvider);
                    await tableService.createTable(
                      _tableNameController.text,
                      _columns,
                    );
                    Navigator.pop(context);
                    _refreshTables();
                    _showSnackbar('Table created successfully');
                  } catch (e) {
                    _showSnackbar('Error creating table: $e');
                  }
                }
              },
              child: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDropTableDialog(BuildContext context, String tableName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Drop Table'),
        content: Text(
          'Are you sure you want to drop the table "$tableName"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final tableService = ref.read(tableServiceProvider);
                await tableService.dropTable(tableName);
                Navigator.pop(context);
                _refreshTables();
                if (ref.read(selectedTableProvider) == tableName) {
                  ref.read(selectedTableProvider.notifier).state = null;
                  ref.read(tableDataProvider.notifier).state = [];
                }
                _showSnackbar('Table dropped successfully');
              } catch (e) {
                _showSnackbar('Error dropping table: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Drop'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Database'),
        content: Text(
          'Are you sure you want to delete this database? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final dbService = ref.read(databaseServiceProvider);
                await dbService.deleteDB();
                ref.read(databaseInfoProvider.notifier).state = null;
                ref.read(tableListProvider.notifier).state = [];
                Navigator.pop(context);
                _showSnackbar('Database deleted successfully');
              } catch (e) {
                _showSnackbar('Error deleting database: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
