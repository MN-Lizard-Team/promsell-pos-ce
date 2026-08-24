import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/database/database_health_service.dart';
import 'package:promsell_pos_ce/core/database/migration_safety_service.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DbHealthPage extends StatefulWidget {
  const DbHealthPage({super.key});

  @override
  State<DbHealthPage> createState() => _DbHealthPageState();
}

class _DbHealthPageState extends State<DbHealthPage> {
  /// Low-disk threshold for the warning banner (200 MB).
  static const _lowDiskThresholdBytes = 200 * 1024 * 1024;

  bool _isLoading = true;
  int? _fileSizeBytes;
  int? _freeStorageBytes;
  Map<String, int>? _rowCounts;
  MigrationStatus? _migrationStatus;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHealth();
  }

  Future<void> _loadHealth() async {
    try {
      final healthService = sl<DatabaseHealthService>();
      final report = await healthService.generateReport();
      final rowCounts = await healthService.countRows();
      final migrationStatus = await sl<MigrationSafetyService>()
          .readMigrationStatus();

      if (mounted) {
        setState(() {
          _fileSizeBytes = report.mainDbSize;
          _freeStorageBytes = report.freeStorageBytes;
          _rowCounts = rowCounts;
          _migrationStatus = migrationStatus;
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
      await sl<DatabaseHealthService>().vacuum();
      if (mounted) {
        AppSnackBar.success(context, context.l10n.dbHealthVacuumSuccess);
        await _loadHealth();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          context.l10n.dbHealthVacuumFailed(e.toString()),
        );
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Free-space label; "Unknown" when the platform could not measure it.
  String _freeStorageLabel(AppLocalizations l10n) {
    final bytes = _freeStorageBytes;
    if (bytes == null || bytes < 0) return l10n.dbHealthUnknown;
    return _formatSize(bytes);
  }

  String _migrationStatusLabel(AppLocalizations l10n) {
    switch (_migrationStatus!) {
      case MigrationStatus.idle:
        return l10n.dbHealthMigrationNone;
      case MigrationStatus.running:
        return l10n.dbHealthMigrationRunning;
      case MigrationStatus.succeeded:
        return l10n.dbHealthMigrationSucceeded;
      case MigrationStatus.failed:
        return l10n.dbHealthMigrationFailed;
    }
  }

  bool get _isLowDisk =>
      (_freeStorageBytes ?? -1) >= 0 &&
      _freeStorageBytes! < _lowDiskThresholdBytes;

  bool get _isMigrationInterrupted =>
      _migrationStatus == MigrationStatus.running ||
      _migrationStatus == MigrationStatus.failed;

  bool get _isLargeDb => (_fileSizeBytes ?? 0) > 50 * 1024 * 1024; // > 50 MB

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.dbHealthTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? AppEmptyState(
              icon: Icons.error_outline,
              title: context.l10n.dbHealthError(_error!),
            )
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

                // Free storage card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.sd_storage),
                    title: Text(context.l10n.dbHealthFreeStorage),
                    subtitle: Text(_freeStorageLabel(context.l10n)),
                    trailing:
                        _freeStorageBytes != null && _freeStorageBytes! >= 0
                        ? Chip(
                            label: Text(
                              _isLowDisk
                                  ? context.l10n.dbHealthLow
                                  : context.l10n.dbHealthOk,
                              style: TextStyle(
                                color: _isLowDisk
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            backgroundColor: _isLowDisk
                                ? Theme.of(context).colorScheme.errorContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),

                // Migration status card (surfaces interrupted migrations).
                if (_migrationStatus != null)
                  Card(
                    color: _isMigrationInterrupted
                        ? Theme.of(context).colorScheme.errorContainer
                        : null,
                    child: ListTile(
                      leading: Icon(
                        _isMigrationInterrupted
                            ? Icons.sync_problem
                            : Icons.sync,
                        color: _isMigrationInterrupted
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                      title: Text(context.l10n.dbHealthMigrationStatus),
                      trailing: Text(_migrationStatusLabel(context.l10n)),
                    ),
                  ),
                const SizedBox(height: 8),

                // Warnings
                if (_isLowDisk)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.warning_amber,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(context.l10n.dbHealthLowStorageTitle),
                      subtitle: Text(
                        context.l10n.dbHealthLowStorageMessage(
                          _freeStorageLabel(context.l10n),
                        ),
                      ),
                    ),
                  ),
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
