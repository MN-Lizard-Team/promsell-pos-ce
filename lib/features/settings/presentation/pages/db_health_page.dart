import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

class DbHealthPage extends StatefulWidget {
  const DbHealthPage({super.key});

  @override
  State<DbHealthPage> createState() => _DbHealthPageState();
}

class _DbHealthPageState extends State<DbHealthPage> {
  bool _isLoading = true;
  int? _fileSizeBytes;
  Map<String, int>? _rowCounts;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
    try {
      final db = sl<AppDatabase>();
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File('${dbFolder.path}/promsell_pos.db');
      final fileSize = await dbFile.exists() ? await dbFile.length() : 0;

      final rowCounts = <String, int>{};
      rowCounts['Products'] = await db
          .select(db.products)
          .get()
          .then((r) => r.length);
      rowCounts['Sales'] = await db
          .select(db.sales)
          .get()
          .then((r) => r.length);
      rowCounts['Sale Items'] = await db
          .select(db.saleItems)
          .get()
          .then((r) => r.length);
      rowCounts['Categories'] = await db
          .select(db.categories)
          .get()
          .then((r) => r.length);
      rowCounts['Inventory Logs'] = await db
          .select(db.inventoryLogs)
          .get()
          .then((r) => r.length);
      rowCounts['Draft Carts'] = await db
          .select(db.draftCarts)
          .get()
          .then((r) => r.length);
      rowCounts['Daily Closes'] = await db
          .select(db.dailyCloses)
          .get()
          .then((r) => r.length);
      rowCounts['App Settings'] = await db
          .select(db.appSettings)
          .get()
          .then((r) => r.length);

      if (mounted) {
        setState(() {
          _fileSizeBytes = fileSize;
          _rowCounts = rowCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _vacuum() async {
    try {
      final db = sl<AppDatabase>();
      await db.customStatement('VACUUM');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.dbHealthVacuumSuccess)),
        );
        await _loadHealth();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.dbHealthVacuumFailed(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get _isLargeDb => (_fileSizeBytes ?? 0) > 50 * 1024 * 1024; // > 50 MB

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.dbHealthTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(context.l10n.dbHealthError(_error!)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // File size card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.storage),
                    title: Text(context.l10n.dbHealthFileSize),
                    subtitle: Text(_formatSize(_fileSizeBytes ?? 0)),
                    trailing: _isLargeDb
                        ? Chip(
                            label: Text(
                              context.l10n.dbHealthLarge,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                          )
                        : Chip(
                            label: Text(
                              context.l10n.dbHealthOk,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                          ),
                  ),
                ),
                const SizedBox(height: 8),

                // Warnings
                if (_isLargeDb)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(context.l10n.dbHealthLargeTitle),
                      subtitle: Text(context.l10n.dbHealthLargeMessage),
                    ),
                  ),
                const SizedBox(height: 8),

                // Row counts
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          context.l10n.dbHealthRowCounts,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      ...(_rowCounts?.entries ?? []).map(
                        (e) => ListTile(
                          dense: true,
                          title: Text(e.key),
                          trailing: Text('${e.value}'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Vacuum button
                FilledButton.icon(
                  onPressed: _vacuum,
                  icon: const Icon(Icons.cleaning_services),
                  label: Text(context.l10n.dbHealthVacuum),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.dbHealthVacuumDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}
