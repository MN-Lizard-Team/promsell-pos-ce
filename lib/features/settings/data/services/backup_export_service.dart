import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_encryption_service.dart';
import 'package:share_plus/share_plus.dart';

/// Metadata written alongside a backup file.
class BackupMetadata {
  const BackupMetadata({
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.dbSizeBytes,
    required this.checksumSha256,
    required this.encrypted,
  });

  final int schemaVersion;
  final String appVersion;
  final String createdAt;
  final int dbSizeBytes;
  final String checksumSha256;
  final bool encrypted;

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'createdAt': createdAt,
    'dbSizeBytes': dbSizeBytes,
    'checksumSha256': checksumSha256,
    'encrypted': encrypted,
  };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) => BackupMetadata(
    schemaVersion: json['schemaVersion'] as int? ?? 0,
    appVersion: json['appVersion'] as String? ?? 'unknown',
    createdAt: json['createdAt'] as String? ?? '',
    dbSizeBytes: json['dbSizeBytes'] as int? ?? 0,
    checksumSha256: json['checksumSha256'] as String? ?? '',
    encrypted: json['encrypted'] as bool? ?? false,
  );

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());

  static BackupMetadata? tryDecode(String? content) {
    if (content == null || content.isEmpty) return null;
    try {
      return BackupMetadata.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Result of a backup export with metadata.
class BackupExportResult {
  const BackupExportResult({
    required this.filePath,
    required this.metadata,
    required this.metadataPath,
  });

  final String filePath;
  final BackupMetadata metadata;
  final String? metadataPath;
}

/// Progress stages reported during backup export.
enum BackupProgress {
  idle,
  checkpointing,
  copying,
  checksumming,
  encrypting,
  sharing,
  done,
}

/// Extension of [BackupProgress] with a description.
extension BackupProgressX on BackupProgress {
  String get label => switch (this) {
    BackupProgress.idle => 'idle',
    BackupProgress.checkpointing => 'checkpointing WAL',
    BackupProgress.copying => 'copying database',
    BackupProgress.checksumming => 'computing checksum',
    BackupProgress.encrypting => 'encrypting backup',
    BackupProgress.sharing => 'sharing file',
    BackupProgress.done => 'done',
  };
}

/// Exports a consistent copy of the local SQLite DB for merchant backup.
@LazySingleton()
class BackupExportService {
  BackupExportService(this._db, this._encryption, this._appLock);

  static const dbFileName = 'promsell_pos.db';
  static const metadataExtension = '.meta.json';

  /// Minimum PIN length when backup encryption is enabled (enforced here, not UI-only).
  static const minPinLength = 6;

  /// Maximum backup file size (512 MB, aligned with restore limit).
  static const maxBackupBytes = 512 * 1024 * 1024;

  final AppDatabase _db;
  final BackupEncryptionService _encryption;
  final AppLockService _appLock;

  /// Checkpoints WAL, copies DB, optionally encrypts, shares the file.
  /// Returns the shared file path. Caller should set lastBackupAt on success.
  Future<String> exportAndShare({
    required bool encrypt,
    String? pin,
    required String shareSubject,
  }) async {
    final result = await exportWithMetadata(
      encrypt: encrypt,
      pin: pin,
      shareSubject: shareSubject,
    );
    return result.filePath;
  }

  /// Full export with checksum, metadata, size preflight, and progress.
  ///
  /// [onProgress] is called at each stage of the export. [appVersion] is
  /// included in the metadata for cross-version restore validation.
  ///
  /// Throws [StateError] with code `BACKUP_TOO_LARGE` if the DB file exceeds
  /// [maxBackupBytes] before the copy begins.
  Future<BackupExportResult> exportWithMetadata({
    required bool encrypt,
    String? pin,
    required String shareSubject,
    String appVersion = 'unknown',
    void Function(BackupProgress stage)? onProgress,
  }) async {
    final result = await exportToFiles(
      encrypt: encrypt,
      pin: pin,
      appVersion: appVersion,
      onProgress: onProgress,
    );

    onProgress?.call(BackupProgress.sharing);
    final files = [XFile(result.filePath)];
    if (result.metadataPath != null) {
      files.add(XFile(result.metadataPath!));
    }
    await SharePlus.instance.share(
      ShareParams(files: files, subject: shareSubject),
    );

    onProgress?.call(BackupProgress.done);
    return result;
  }

  /// Export to files without sharing — testable without Flutter bindings.
  ///
  /// Performs size preflight, WAL checkpoint, copy, checksum, metadata
  /// write, and optional encryption. Returns the file paths and metadata.
  Future<BackupExportResult> exportToFiles({
    required bool encrypt,
    String? pin,
    String appVersion = 'unknown',
    void Function(BackupProgress stage)? onProgress,
  }) async {
    await _appLock.requireSensitiveSession();
    if (encrypt) {
      final p = pin?.trim() ?? '';
      if (p.isEmpty) {
        throw StateError('PIN_REQUIRED');
      }
      if (p.length < minPinLength) {
        throw StateError('PIN_TOO_SHORT');
      }
    }

    // ── Size preflight ──────────────────────────────────────────────
    final docs = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docs.path, dbFileName));
    if (!await dbFile.exists()) {
      throw StateError('DB_MISSING');
    }
    final dbSize = await dbFile.length();
    if (dbSize > maxBackupBytes) {
      throw StateError('BACKUP_TOO_LARGE');
    }

    // ── Checkpoint + copy ───────────────────────────────────────────
    onProgress?.call(BackupProgress.checkpointing);
    final copyPath = await _createSnapshotCopy();

    // ── Checksum ────────────────────────────────────────────────────
    onProgress?.call(BackupProgress.checksumming);
    final copyFile = File(copyPath);
    final copySize = await copyFile.length();
    final checksum = await _computeSha256(copyFile);

    // ── Schema version ──────────────────────────────────────────────
    final schemaVersionResult = await _db
        .customSelect('PRAGMA user_version')
        .getSingle();
    final schemaVersion = schemaVersionResult.read<int>('user_version');

    final metadata = BackupMetadata(
      schemaVersion: schemaVersion,
      appVersion: appVersion,
      createdAt: DateTime.now().toIso8601String(),
      dbSizeBytes: copySize,
      checksumSha256: checksum,
      encrypted: encrypt,
    );

    // Write metadata file alongside the backup.
    final metadataPath = '$copyPath$metadataExtension';
    await File(metadataPath).writeAsString(metadata.encode());

    // ── Encrypt (optional) ──────────────────────────────────────────
    String sharePath = copyPath;
    String? shareMetadataPath = metadataPath;
    try {
      if (encrypt) {
        onProgress?.call(BackupProgress.encrypting);
        sharePath = await _encryption.encryptFile(
          sourcePath: copyPath,
          pin: pin!.trim(),
        );
        await _safeDelete(copyPath);
        // Rewrite metadata for the encrypted file.
        final encMetadata = BackupMetadata(
          schemaVersion: schemaVersion,
          appVersion: appVersion,
          createdAt: metadata.createdAt,
          dbSizeBytes: await File(sharePath).length(),
          checksumSha256: await _computeSha256(File(sharePath)),
          encrypted: true,
        );
        shareMetadataPath = '$sharePath$metadataExtension';
        await File(shareMetadataPath).writeAsString(encMetadata.encode());
        await _safeDelete(metadataPath);
        return BackupExportResult(
          filePath: sharePath,
          metadata: encMetadata,
          metadataPath: shareMetadataPath,
        );
      }

      return BackupExportResult(
        filePath: sharePath,
        metadata: metadata,
        metadataPath: shareMetadataPath,
      );
    } finally {
      // Clean up plain copy if encrypted (share path is the .enc file).
      if (encrypt && sharePath != copyPath) {
        await _safeDelete(copyPath);
      }
    }
  }

  /// Computes the SHA-256 checksum of a file.
  Future<String> _computeSha256(File file) async {
    final stream = file.openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }

  /// Validates a backup file against its metadata.
  ///
  /// Returns true if the file exists, size matches, and checksum matches.
  /// Returns false if the metadata is missing or the validation fails.
  Future<bool> validateAgainstMetadata(String backupPath) async {
    final metadataPath = '$backupPath$metadataExtension';
    final metadataFile = File(metadataPath);
    if (!await metadataFile.exists()) return false;

    final metadata = BackupMetadata.tryDecode(
      await metadataFile.readAsString(),
    );
    if (metadata == null) return false;

    final backupFile = File(backupPath);
    if (!await backupFile.exists()) return false;

    final actualSize = await backupFile.length();
    if (actualSize != metadata.dbSizeBytes) return false;

    final actualChecksum = await _computeSha256(backupFile);
    return actualChecksum == metadata.checksumSha256;
  }

  Future<String> _createSnapshotCopy() async {
    return _db.exclusively(() async {
      try {
        await _db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
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
      return copyPath;
    });
  }

  Future<void> _safeDelete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (e, stack) {
      AppLogger.warning(
        'backup_export: _safeDelete failed for $path',
        error: e,
        stack: stack,
      );
    }
  }
}
