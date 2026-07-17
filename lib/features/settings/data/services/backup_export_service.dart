import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:share_plus/share_plus.dart';

/// Exports a consistent copy of the local SQLite DB for merchant backup.
@LazySingleton()
class BackupExportService {
  BackupExportService(this._db, this._encryption);

  static const dbFileName = 'promsell_pos.db';

  /// Minimum PIN length when backup encryption is enabled (enforced here, not UI-only).
  static const minPinLength = 6;

  final AppDatabase _db;
  final BackupEncryptionService _encryption;

  /// Checkpoints WAL, copies DB, optionally encrypts, shares the file.
  /// Returns the shared file path. Caller should set lastBackupAt on success.
  Future<String> exportAndShare({
    required bool encrypt,
    String? pin,
    required String shareSubject,
  }) async {
    if (encrypt) {
      final p = pin?.trim() ?? '';
      if (p.isEmpty) {
        throw StateError('PIN_REQUIRED');
      }
      if (p.length < minPinLength) {
        throw StateError('PIN_TOO_SHORT');
      }
    }

    try {
      await _db.customStatement('PRAGMA wal_checkpoint(FULL)');
    } catch (e, st) {
      AppLogger.error(
        'BackupExportService: wal_checkpoint failed',
        error: e,
        stack: st,
      );
      throw StateError('CHECKPOINT_FAILED');
    }

    final docs = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docs.path, dbFileName));
    if (!await dbFile.exists()) {
      throw StateError('DB_MISSING');
    }

    final tempDir = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final copyPath = p.join(tempDir.path, 'promsell_backup_$stamp.db');
    await dbFile.copy(copyPath);

    String sharePath = copyPath;
    try {
      if (encrypt) {
        sharePath = await _encryption.encryptFile(
          sourcePath: copyPath,
          pin: pin!.trim(),
        );
        await _safeDelete(copyPath);
      }

      await SharePlus.instance.share(
        ShareParams(files: [XFile(sharePath)], subject: shareSubject),
      );
      return sharePath;
    } finally {
      // Leave shared path for OS share handoff; clean plain copy if still there.
      if (sharePath != copyPath) {
        await _safeDelete(copyPath);
      }
    }
  }

  Future<void> _safeDelete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
