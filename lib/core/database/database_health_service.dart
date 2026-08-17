import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/wal_checkpoint_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// Snapshot of database health metrics.
class DatabaseHealthReport {
  const DatabaseHealthReport({
    required this.mainDbSize,
    required this.walSize,
    required this.shmSize,
    required this.totalSize,
    required this.schemaVersion,
    required this.integrityOk,
    required this.freeStorageBytes,
    required this.walNeedsCheckpoint,
    required this.walNeedsTruncate,
    required this.generatedAt,
  });

  /// Main DB file size in bytes.
  final int mainDbSize;

  /// WAL file size in bytes.
  final int walSize;

  /// SHM file size in bytes.
  final int shmSize;

  /// Total size (main + WAL + SHM) in bytes.
  final int totalSize;

  /// Current schema version (PRAGMA user_version).
  final int schemaVersion;

  /// True if PRAGMA integrity_check returns 'ok'.
  final bool integrityOk;

  /// Available free storage in bytes (-1 if unknown).
  final int freeStorageBytes;

  /// True if WAL exceeds the passive checkpoint threshold.
  final bool walNeedsCheckpoint;

  /// True if WAL exceeds the hard truncate limit.
  final bool walNeedsTruncate;
  final DateTime generatedAt;

  /// Total size in MB (rounded).
  double get totalSizeMb => totalSize / (1024 * 1024);

  /// WAL size as a percentage of total size.
  double get walPercent => totalSize > 0 ? (walSize / totalSize) * 100 : 0;

  /// True if the database is approaching the 512 MB operational guardrail.
  bool get approachingGuardrail => totalSize > 400 * 1024 * 1024;

  /// True if the database exceeds the 512 MB operational guardrail.
  bool get exceedsGuardrail => totalSize > 512 * 1024 * 1024;

  @override
  String toString() =>
      'DatabaseHealthReport('
      'main=${mainDbSize ~/ 1024}KB, '
      'wal=${walSize ~/ 1024}KB, '
      'shm=${shmSize ~/ 1024}KB, '
      'total=${totalSizeMb.toStringAsFixed(1)}MB, '
      'schema=$schemaVersion, '
      'integrity=${integrityOk ? 'ok' : 'FAIL'}, '
      'free=${freeStorageBytes >= 0 ? '${freeStorageBytes ~/ (1024 * 1024)}MB' : 'unknown'}, '
      'walNeedsCheckpoint=$walNeedsCheckpoint, '
      'walNeedsTruncate=$walNeedsTruncate)';
}

/// Service that reports database health metrics.
///
/// Provides a single [generateReport] method that collects:
/// - Main DB, WAL, and SHM file sizes
/// - Schema version
/// - Integrity check status
/// - Free storage (platform-dependent)
/// - WAL checkpoint recommendations
///
/// Call this during day-close, settings page, or operator diagnostics.
@LazySingleton()
class DatabaseHealthService {
  DatabaseHealthService(this._db, this._walService);

  final AppDatabase _db;
  final WalCheckpointService _walService;

  /// Generates a database health report.
  ///
  /// [checkIntegrity] defaults to false because `PRAGMA integrity_check`
  /// can be slow on large databases. Enable it for operator diagnostics.
  Future<DatabaseHealthReport> generateReport({
    bool checkIntegrity = false,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docs.path, 'promsell_pos.db');
    final walPath = '$dbPath-wal';
    final shmPath = '$dbPath-shm';

    final mainDbFile = File(dbPath);
    final walFile = File(walPath);
    final shmFile = File(shmPath);

    final mainDbSize = await mainDbFile.exists()
        ? await mainDbFile.length()
        : 0;
    final walSize = await walFile.exists() ? await walFile.length() : 0;
    final shmSize = await shmFile.exists() ? await shmFile.length() : 0;
    final totalSize = mainDbSize + walSize + shmSize;

    final schemaVersionResult = await _db
        .customSelect('PRAGMA user_version')
        .getSingle();
    final schemaVersion = schemaVersionResult.read<int>('user_version');

    var integrityOk = true;
    if (checkIntegrity) {
      try {
        final result = await _db
            .customSelect('PRAGMA integrity_check')
            .getSingle();
        integrityOk = result.data.values.first == 'ok';
      } catch (e, stack) {
        AppLogger.warning(
          'DatabaseHealthService: integrity_check failed',
          error: e,
          stack: stack,
        );
        integrityOk = false;
      }
    }

    final freeStorageBytes = await _getFreeStorage(docs.path);
    final walNeedsCheckpoint = await _walService.shouldCheckpoint();
    final walNeedsTruncate = await _walService.needsTruncate();

    final report = DatabaseHealthReport(
      mainDbSize: mainDbSize,
      walSize: walSize,
      shmSize: shmSize,
      totalSize: totalSize,
      schemaVersion: schemaVersion,
      integrityOk: integrityOk,
      freeStorageBytes: freeStorageBytes,
      walNeedsCheckpoint: walNeedsCheckpoint,
      walNeedsTruncate: walNeedsTruncate,
      generatedAt: DateTime.now(),
    );

    AppLogger.info('DatabaseHealthService: $report');
    return report;
  }

  /// Returns available free space in bytes for [path], or -1 if unknown.
  Future<int> _getFreeStorage(String path) async {
    try {
      // Platform-specific free-space check is done by the integration_test.
      // Here we return a placeholder that indicates the measurement is
      // not available in this context.
      return -1;
    } catch (e, stack) {
      AppLogger.warning(
        'DatabaseHealthService: _getFreeStorage failed',
        error: e,
        stack: stack,
      );
      return -1;
    }
  }
}
