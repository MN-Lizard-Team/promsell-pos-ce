import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/db_key_store.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

/// Database opener with transparent plain→encrypted migration (Phase 2a / v0.9.0).
///
/// On first launch after upgrade:
/// 1. Detects if the existing DB is plain SQLite (via header check)
/// 2. If plain: uses SQLCipher's `sqlcipher_export` to create encrypted copy
/// 3. Replaces the plain DB with the encrypted copy atomically
/// 4. Keeps a `.bak` backup until migration succeeds
///
/// All subsequent opens use the encrypted database with `PRAGMA key`.
class EncryptedDatabaseOpener {
  EncryptedDatabaseOpener._();

  static const _dbName = 'promsell_pos.db';
  static const _sqliteHeader = [
    83,
    81,
    76,
    105,
    116,
    101,
    32,
    102,
    111,
    114,
    109,
    97,
    116,
    32,
    51,
    0,
  ]; // "SQLite format 3\0"

  /// Loads the SQLCipher native library.
  ///
  /// sqlcipher_flutter_libs provides libsqlcipher.so on Android (not
  /// libsqlite3.so). On iOS, SQLCipher is statically linked and
  /// DynamicLibrary.process() finds it automatically.
  static void _loadSqlcipherLibrary() {
    if (Platform.isAndroid) {
      sqlite3_open.open.overrideFor(
        sqlite3_open.OperatingSystem.android,
        openCipherOnAndroid,
      );
    }
  }

  /// Opens the database with SQLCipher AES-256-CBC encryption.
  /// Performs one-shot plain→encrypted migration if needed.
  static Future<QueryExecutor> open() async {
    _loadSqlcipherLibrary();

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _dbName));
    final hexKey = await DbKeyStore.getOrCreateKey();
    await _recoverInterruptedMigration(file, hexKey);

    if (await file.exists() && await _isPlainSqlite(file)) {
      await _migrateToEncrypted(file, hexKey);
    }

    // V092-E.2: open the DB on a background isolate so first-run SQLCipher
    // migrate does not stall the UI thread. The `setup` callback runs on
    // the background isolate — `PRAGMA key` is the first statement.
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) => rawDb.execute("PRAGMA key=\"x'$hexKey'\""),
    );
  }

  /// Repairs files left by a process interruption during plain→encrypted
  /// migration before Drift opens the database.
  static Future<void> _recoverInterruptedMigration(
    File file,
    String hexKey,
  ) async {
    final backup = File('${file.path}.bak');
    final encrypted = File('${file.path}.enc');
    final plainTemp = File('${file.path}.plain-migrating');
    final hasArtifacts =
        await backup.exists() ||
        await encrypted.exists() ||
        await plainTemp.exists();
    if (!hasArtifacts) return;

    if (await file.exists()) {
      if (await _isPlainSqlite(file)) {
        // The source survived. Discard incomplete migration artifacts and let
        // the normal migration path start from the intact plain database.
        await _safeDelete(backup);
        await _safeDelete(encrypted);
        await _safeDelete(plainTemp);
        return;
      }

      try {
        await _validateEncryptedCopy(file, hexKey);
        // The encrypted replacement is usable. Remove any plaintext remnants.
        await _safeDelete(backup);
        await _safeDelete(encrypted);
        await _safeDelete(plainTemp);
        return;
      } catch (e, stack) {
        AppLogger.warning(
          'database_opener: encrypted copy validation failed, falling through to recovery',
          error: e,
          stack: stack,
        );
      }

      final recovery = await _firstExisting([plainTemp, backup]);
      if (recovery == null) {
        throw StateError('DATABASE_RECOVERY_FAILED');
      }
      await _safeDelete(file);
      await recovery.rename(file.path);
      await _safeDelete(backup);
      await _safeDelete(encrypted);
      await _safeDelete(plainTemp);
      return;
    }

    // A crash after removing the live path leaves either an encrypted
    // candidate or a plain recovery copy. Prefer the validated encrypted file.
    if (await encrypted.exists()) {
      try {
        await _validateEncryptedCopy(encrypted, hexKey);
        await encrypted.rename(file.path);
        await _safeDelete(backup);
        await _safeDelete(plainTemp);
        return;
      } catch (e, stack) {
        AppLogger.warning(
          'database_opener: encrypted candidate corrupt, restoring plain copy',
          error: e,
          stack: stack,
        );
      }
    }

    final recovery = await _firstExisting([plainTemp, backup]);
    if (recovery == null) {
      throw StateError('DATABASE_RECOVERY_FAILED');
    }
    await recovery.rename(file.path);
    await _safeDelete(encrypted);
    await _safeDelete(backup);
    await _safeDelete(plainTemp);
  }

  static Future<File?> _firstExisting(List<File> candidates) async {
    for (final candidate in candidates) {
      if (await candidate.exists()) return candidate;
    }
    return null;
  }

  /// Checks if the database file is plain (unencrypted) SQLite.
  /// Returns true if the first 16 bytes match "SQLite format 3\0".
  static Future<bool> _isPlainSqlite(File file) async {
    try {
      final bytes = await file.openRead(0, 16).expand((c) => c).toList();
      if (bytes.length < 16) return false;
      for (var i = 0; i < 16; i++) {
        if (bytes[i] != _sqliteHeader[i]) return false;
      }
      return true;
    } catch (e, stack) {
      AppLogger.warning(
        'database_opener: _isPlainSqlite check failed',
        error: e,
        stack: stack,
      );
      return false;
    }
  }

  /// Migrates a plain SQLite database to SQLCipher encryption in-place.
  ///
  /// Uses SQLCipher's [sqlcipher_export] function to copy all data into
  /// a new encrypted database, then atomically replaces the original file.
  ///
  /// Creates a `.bak` backup before migration. On success, the backup is removed.
  /// On failure, the backup is restored automatically.
  static Future<void> _migrateToEncrypted(File plain, String hexKey) async {
    final backupPath = '${plain.path}.bak';
    final encPath = '${plain.path}.enc';
    final backup = File(backupPath);
    final enc = File(encPath);
    final plainTemp = File('${plain.path}.plain-migrating');
    var replacementCompleted = false;

    // Remove stale output from a previous interrupted attempt. A stale
    // encrypted candidate must never be mistaken for a valid migration.
    if (await enc.exists()) await enc.delete();

    // Keep one recovery copy while the source is still plain.
    await plain.copy(backupPath);

    try {
      // Wrap in a minimal GeneratedDatabase to get access to customStatement.
      // SQLCipher opens plain SQLite databases transparently (no key needed).
      final db = _PlainDatabase(NativeDatabase(plain));
      try {
        await db.customStatement(
          'ATTACH DATABASE \'$encPath\' AS encrypted KEY "x\'$hexKey\'"',
        );
        await db.customStatement("SELECT sqlcipher_export('encrypted')");
        await db.customStatement('DETACH DATABASE encrypted');
      } finally {
        await db.close();
      }

      await _validateEncryptedCopy(enc, hexKey);

      // Keep the old file recoverable until the encrypted output has been
      // installed successfully. Rename is same-filesystem and avoids copying
      // a partially written candidate over the live path.
      await plain.rename(plainTemp.path);
      try {
        await enc.rename(plain.path);
        replacementCompleted = true;
        await plainTemp.delete();
      } catch (e, stack) {
        AppLogger.warning(
          'database_opener: encrypted rename failed, attempting plain restore',
          error: e,
          stack: stack,
        );
        if (!await plain.exists() && await plainTemp.exists()) {
          await plainTemp.rename(plain.path);
        }
        rethrow;
      }
    } finally {
      // A plaintext backup is useful only while the migration is in flight.
      // Never leave it behind after either success or a restored failure path.
      if (replacementCompleted || await plain.exists()) {
        await _safeDelete(backup);
      }
      await _safeDelete(enc);
      await _safeDelete(plainTemp);
    }
  }

  static Future<void> _validateEncryptedCopy(
    File encrypted,
    String hexKey,
  ) async {
    if (!await encrypted.exists() || await encrypted.length() < 16) {
      throw StateError('ENCRYPTED_MIGRATION_OUTPUT_INVALID');
    }

    final db = _PlainDatabase(
      NativeDatabase(
        encrypted,
        setup: (rawDb) => rawDb.execute("PRAGMA key=\"x'$hexKey'\""),
      ),
    );
    try {
      final integrity = await db
          .customSelect('PRAGMA integrity_check')
          .getSingle();
      if (integrity.data.values.first != 'ok') {
        throw StateError('ENCRYPTED_MIGRATION_INTEGRITY_FAILED');
      }
      final tableCount = await db
          .customSelect(
            "SELECT COUNT(*) AS count FROM sqlite_master WHERE type='table'",
          )
          .getSingle();
      if ((tableCount.data['count'] as int? ?? 0) == 0) {
        throw StateError('ENCRYPTED_MIGRATION_SCHEMA_EMPTY');
      }
    } finally {
      await db.close();
    }
  }

  static Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (e, stack) {
      AppLogger.warning(
        'database_opener: _safeDelete failed for ${file.path}',
        error: e,
        stack: stack,
      );
    }
  }
}

/// Minimal stub database used only during the plain→encrypted migration.
/// Provides access to [customStatement] without declaring any tables.
class _PlainDatabase extends GeneratedDatabase {
  _PlainDatabase(super.e);

  @override
  Iterable<TableInfo<Table, DataClass>> get allTables => const Iterable.empty();

  @override
  int get schemaVersion => 1;
}
