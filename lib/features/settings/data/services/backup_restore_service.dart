import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_export_service.dart';

/// Same-device restore of a SQLCipher DB backup (optional AES-GCM PIN envelope).
///
/// Requires the existing [DbKeyStore] key on this device. Cross-device / after
/// uninstall is intentionally unsupported (Phase 2b).
@LazySingleton()
class BackupRestoreService {
  BackupRestoreService(this._db, this._encryption);

  final AppDatabase _db;
  final BackupEncryptionService _encryption;

  static const minPinLength = BackupExportService.minPinLength;

  /// Restores [sourcePath] (.enc or .db). Returns path of the pre-restore backup.
  ///
  /// Caller must restart the app process so Drift/GetIt reopen the DB cleanly.
  Future<String> restoreFromPath({
    required String sourcePath,
    String? pin,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('SOURCE_MISSING');
    }

    final lower = sourcePath.toLowerCase();
    final looksEncrypted = lower.endsWith('.enc');
    final p0 = pin?.trim() ?? '';
    if (looksEncrypted) {
      if (p0.isEmpty) throw StateError('PIN_REQUIRED');
      if (p0.length < minPinLength) throw StateError('PIN_TOO_SHORT');
    } else {
      // Reject plain SQLite before any path_provider / file swap work.
      await _assertSqlCipherCandidate(sourcePath);
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
        await _assertSqlCipherCandidate(workingPath);
      }

      final docs = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docs.path, BackupExportService.dbFileName);
      final walPath = '$dbPath-wal';
      final shmPath = '$dbPath-shm';
      final preRestorePath = p.join(
        docs.path,
        'promsell_pos.pre_restore_$stamp.db',
      );

      // Close live connection before swapping files.
      try {
        await _db.close();
      } catch (e, st) {
        AppLogger.warning(
          'BackupRestoreService: db.close failed (continuing)',
          error: e,
          stack: st,
        );
      }

      final live = File(dbPath);
      if (await live.exists()) {
        await live.copy(preRestorePath);
      }

      await File(workingPath).copy(dbPath);
      await _safeDelete(walPath);
      await _safeDelete(shmPath);

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

  Future<void> _safeDelete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
