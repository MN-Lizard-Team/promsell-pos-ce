import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// WAL checkpoint mode.
///
/// See https://www.sqlite.org/wal.html#ckpt for details.
enum CheckpointMode { passive, full, restart, truncate }

/// Extension of [CheckpointMode] with SQL names.
extension CheckpointModeX on CheckpointMode {
  String get sqlName => switch (this) {
    CheckpointMode.passive => 'PASSIVE',
    CheckpointMode.full => 'FULL',
    CheckpointMode.restart => 'RESTART',
    CheckpointMode.truncate => 'TRUNCATE',
  };
}

/// Result of a WAL checkpoint operation.
class CheckpointResult {
  const CheckpointResult({
    required this.mode,
    required this.busy,
    required this.logFrames,
    required this.checkpointedFrames,
    required this.walSizeBefore,
    required this.walSizeAfter,
    required this.elapsedMs,
  });

  final CheckpointMode mode;

  /// 1 if the checkpoint was busy (a reader was active), 0 otherwise.
  final int busy;

  /// Number of frames in the WAL log.
  final int logFrames;

  /// Number of frames checkpointed.
  final int checkpointedFrames;

  /// WAL file size in bytes before the checkpoint.
  final int walSizeBefore;

  /// WAL file size in bytes after the checkpoint.
  final int walSizeAfter;
  final int elapsedMs;

  bool get wasBusy => busy == 1;
  bool get walTruncated => walSizeAfter == 0;

  @override
  String toString() =>
      'CheckpointResult(mode=$mode, busy=$busy, '
      'frames=$logFrames→$checkpointedFrames, '
      'wal=${walSizeBefore}B→${walSizeAfter}B, ${elapsedMs}ms)';
}

/// Service that manages WAL checkpointing and monitoring.
///
/// **Policy:**
/// - Use [CheckpointMode.passive] for periodic background checkpoints — it
///   never blocks readers or writers and is safe during money transactions.
/// - Use [CheckpointMode.truncate] only during backup/export or day-close
///   when the app can briefly hold an exclusive lock.
/// - Never use [CheckpointMode.full] or [CheckpointMode.restart] during
///   active sale writing — they can block writers.
///
/// **Monitoring:**
/// - [getWalSize] returns the current WAL file size in bytes.
/// - [shouldCheckpoint] returns true when the WAL exceeds
///   [_walCheckpointThreshold].
@LazySingleton()
class WalCheckpointService {
  WalCheckpointService(this._db);

  final AppDatabase _db;

  /// WAL size threshold (bytes) that triggers a passive checkpoint.
  /// 10 MB is a reasonable default for mobile — large enough to avoid
  /// frequent checkpoints but small enough to keep memory bounded.
  static const int walCheckpointThreshold = 10 * 1024 * 1024;

  /// Maximum WAL size before a forced truncate checkpoint.
  /// 50 MB is the hard limit — beyond this, the WAL is consuming too
  /// much storage and should be truncated at the next safe opportunity.
  static const int walHardLimit = 50 * 1024 * 1024;

  /// Returns the WAL file size in bytes, or 0 if the WAL doesn't exist.
  Future<int> getWalSize() async {
    final docs = await getApplicationDocumentsDirectory();
    final walPath = p.join(docs.path, 'promsell_pos.db-wal');
    final walFile = File(walPath);
    if (!await walFile.exists()) return 0;
    return walFile.length();
  }

  /// Returns the SHM file size in bytes, or 0 if the SHM doesn't exist.
  Future<int> getShmSize() async {
    final docs = await getApplicationDocumentsDirectory();
    final shmPath = p.join(docs.path, 'promsell_pos.db-shm');
    final shmFile = File(shmPath);
    if (!await shmFile.exists()) return 0;
    return shmFile.length();
  }

  /// Returns true if the WAL exceeds the checkpoint threshold.
  Future<bool> shouldCheckpoint() async {
    final walSize = await getWalSize();
    return walSize >= walCheckpointThreshold;
  }

  /// Returns true if the WAL exceeds the hard limit and needs a truncate.
  Future<bool> needsTruncate() async {
    final walSize = await getWalSize();
    return walSize >= walHardLimit;
  }

  /// Runs a WAL checkpoint in the given [mode].
  ///
  /// [CheckpointMode.passive] is safe during active transactions — it
  /// checkpoints as many frames as possible without blocking.
  /// [CheckpointMode.truncate] requires exclusive access and should only
  /// be called from backup/export or day-close.
  Future<CheckpointResult> checkpoint({
    CheckpointMode mode = CheckpointMode.passive,
  }) async {
    final walSizeBefore = await getWalSize();
    final sw = Stopwatch()..start();

    // PRAGMA wal_checkpoint returns (busy, log, checkpointed).
    final result = await _db
        .customSelect('PRAGMA wal_checkpoint(${mode.sqlName})')
        .getSingle();

    final elapsedMs = sw.elapsedMilliseconds;
    final walSizeAfter = await getWalSize();

    final busy = result.read<int>('busy');
    final logFrames = result.read<int>('log');
    final checkpointedFrames = result.read<int>('checkpointed');

    final cr = CheckpointResult(
      mode: mode,
      busy: busy,
      logFrames: logFrames,
      checkpointedFrames: checkpointedFrames,
      walSizeBefore: walSizeBefore,
      walSizeAfter: walSizeAfter,
      elapsedMs: elapsedMs,
    );

    AppLogger.info('WalCheckpointService: $cr');
    return cr;
  }

  /// Runs a passive checkpoint if the WAL exceeds the threshold.
  ///
  /// Safe to call during active money transactions. Returns null if no
  /// checkpoint was needed.
  Future<CheckpointResult?> checkpointIfNeeded() async {
    if (!await shouldCheckpoint()) return null;
    return checkpoint(mode: CheckpointMode.passive);
  }

  /// Forces a truncate checkpoint. Only call when the app can hold an
  /// exclusive lock (backup, export, day-close).
  Future<CheckpointResult> forceTruncate() async {
    return _db.exclusively(() => checkpoint(mode: CheckpointMode.truncate));
  }
}
