import 'dart:io';

import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/db_key_store.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_export_service.dart';

/// Same-device restore of a SQLCipher DB backup (optional AES-GCM PIN envelope).
///
/// Requires the existing [DbKeyStore] key on this device. Cross-device / after
/// uninstall is intentionally unsupported (Phase 2b).

typedef CandidateValidator = Future<void> Function(String path);

@LazySingleton()
class BackupRestoreService {
  BackupRestoreService(
    this._db,
    this._encryption,
    this._appLock, {
    @ignoreParam CandidateValidator? candidateValidator,
    @ignoreParam this.skipSqlCipherHeaderCheck = false,
  }) : _candidateValidator = candidateValidator;

  final AppDatabase _db;
  final Future<void> Function(String path)? _candidateValidator;
  final BackupEncryptionService _encryption;
  final AppLockService _appLock;

  /// When true, skips the SQLCipher header check. Test-only — production
  /// code should never set this. Used by tests that use plain SQLite
  /// fixtures instead of real SQLCipher databases.
  final bool skipSqlCipherHeaderCheck;

  static const minPinLength = BackupExportService.minPinLength;
  static const maxBackupBytes = 512 * 1024 * 1024;

  /// Restores [sourcePath] (.enc or .db). Returns path of the pre-restore backup.
  ///
  /// Caller must restart the app process so Drift/GetIt reopen the DB cleanly.
  Future<String> restoreFromPath({
    required String sourcePath,
    String? pin,
  }) async {
    await _appLock.requireSensitiveSession();

    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('SOURCE_MISSING');
    }
    if (await source.length() > maxBackupBytes) {
      throw StateError('BACKUP_TOO_LARGE');
    }

    final lower = sourcePath.toLowerCase();
    final looksEncrypted = lower.endsWith('.enc');
    final p0 = pin?.trim() ?? '';
    if (looksEncrypted) {
      if (p0.isEmpty) throw StateError('PIN_REQUIRED');
      if (p0.length < minPinLength) throw StateError('PIN_TOO_SHORT');
    } else {
      // Reject plain SQLite before any path_provider / file swap work.
      if (!skipSqlCipherHeaderCheck) {
        await _assertSqlCipherCandidate(sourcePath);
      }
    }

    final tempDir = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    var workingPath = sourcePath;
    String? decryptedTemp;

    try {
      if (looksEncrypted) {
        decryptedTemp = p.join(tempDir.path, 'promsell_restore_$stamp.db');
        workingPath = await _encryption.decryptFile(
          sourcePath: sourcePath,
          pin: p0,
          outputPath: decryptedTemp,
        );
        if (await File(workingPath).length() > maxBackupBytes) {
          throw StateError('BACKUP_TOO_LARGE');
        }
        if (!skipSqlCipherHeaderCheck) {
          await _assertSqlCipherCandidate(workingPath);
        }
      }

      await _validateCandidate(workingPath);

      final docs = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docs.path, BackupExportService.dbFileName);
      final walPath = '$dbPath-wal';
      final shmPath = '$dbPath-shm';
      final preRestorePath = p.join(
        docs.path,
        'promsell_pos.pre_restore_$stamp.db',
      );

      final live = File(dbPath);
      final staged = File('$dbPath.restore-$stamp.stage');
      final oldPath = '$dbPath.restore-$stamp.old';
      final old = File(oldPath);

      // Stage the candidate before closing the live database. The live file is
      // untouched until validation and the copy both succeed.
      await File(workingPath).copy(staged.path);
      if (await live.exists()) {
        await live.copy(preRestorePath);
      }

      try {
        // A close failure can leave active handles writing to the old file. Do
        // not continue into a swap that could produce a split-brain database.
        await _db.close();
        if (await old.exists()) await old.delete();
        if (await live.exists()) await live.rename(oldPath);
        await staged.rename(dbPath);
        await _deleteRequired(walPath);
        await _deleteRequired(shmPath);
        if (await old.exists()) await old.delete();
      } catch (e, st) {
        AppLogger.error(
          'BackupRestoreService: swap failed; attempting rollback',
          error: e,
          stack: st,
        );
        if (await old.exists()) {
          await _safeDelete(dbPath);
          await old.rename(dbPath);
        }
        rethrow;
      } finally {
        await _safeDelete(staged.path);
        await _safeDelete(oldPath);
      }

      AppLogger.info(
        'BackupRestoreService: restored DB; pre_restore=$preRestorePath',
      );
      return preRestorePath;
    } finally {
      if (decryptedTemp != null) {
        await _safeDelete(decryptedTemp);
      }
    }
  }

  /// SQLCipher files are not plain "SQLite format 3" headers.
  Future<void> _assertSqlCipherCandidate(String path) async {
    final f = File(path);
    final len = await f.length();
    if (len < 16) {
      throw StateError('INVALID_BACKUP');
    }
    final raf = await f.open();
    try {
      final header = await raf.read(16);
      final asString = String.fromCharCodes(header);
      // Plain SQLite would need re-key on this device — not supported same-device path.
      if (asString.startsWith('SQLite format 3')) {
        throw StateError('PLAIN_SQLITE_UNSUPPORTED');
      }
    } finally {
      await raf.close();
    }
  }

  Future<void> _validateCandidate(String path) async {
    final validator = _candidateValidator;
    if (validator != null) {
      await validator(path);
      return;
    }

    final key = await DbKeyStore.getOrCreateKey();
    final candidate = AppDatabase.forTesting(
      NativeDatabase(
        File(path),
        setup: (rawDb) => rawDb.execute("PRAGMA key=\"x'$key'\""),
      ),
    );
    try {
      final tables = await candidate
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN "
            "('products','sales','sale_items','sale_payments')",
          )
          .get();
      if (tables.length != 4) throw StateError('INVALID_BACKUP_SCHEMA');

      final integrity = await candidate
          .customSelect('PRAGMA integrity_check')
          .getSingle();
      if (integrity.data.values.first != 'ok') {
        throw StateError('INVALID_BACKUP_INTEGRITY');
      }
      final foreignKeys = await candidate
          .customSelect('PRAGMA foreign_key_check')
          .get();
      if (foreignKeys.isNotEmpty) throw StateError('INVALID_BACKUP_INTEGRITY');
    } finally {
      await candidate.close();
    }
  }

  Future<void> _safeDelete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (e, stack) {
      AppLogger.warning(
        'backup_restore: _safeDelete failed for $path',
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> _deleteRequired(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  /// Deletes leftover `promsell_pos.pre_restore_*.db` files in the app
  /// documents directory (V092-B.4).
  ///
  /// Call after the app starts and the live DB opens successfully. If a
  /// restore failed mid-swap, the pre-restore file is intentionally kept
  /// for rollback — this method only deletes files once the new DB is
  /// healthy, so callers must invoke it after a successful DB open.
  Future<int> cleanupPreRestoreBackups() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(docs.path);
    if (!await dir.exists()) return 0;
    final prefix = 'promsell_pos.pre_restore_';
    final suffix = '.db';
    var removed = 0;
    await for (final entry in dir.list(followLinks: false)) {
      final name = p.basename(entry.path);
      if (entry is File && name.startsWith(prefix) && name.endsWith(suffix)) {
        await _safeDelete(entry.path);
        removed++;
      }
    }
    if (removed > 0) {
      AppLogger.info(
        'BackupRestoreService: cleaned up $removed pre_restore file(s)',
      );
    }
    return removed;
  }
}
