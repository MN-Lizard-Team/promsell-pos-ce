import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/database/db_key_store.dart';
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

    if (await file.exists() && await _isPlainSqlite(file)) {
      await _migrateToEncrypted(file, hexKey);
    }

    return NativeDatabase(
      file,
      setup: (rawDb) => rawDb.execute("PRAGMA key=\"x'$hexKey'\""),
    );
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
    } catch (_) {
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

    // Remove any stale temp file from a previous failed attempt.
    if (await enc.exists()) await enc.delete();

    // Keep a backup in case migration fails.
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

      // Swap files atomically on the same filesystem.
      await plain.delete();
      await enc.rename(plain.path);

      // Remove backup on success.
      if (await backup.exists()) await backup.delete();
    } catch (e) {
      // Restore backup on any error.
      if (await backup.exists() && !await plain.exists()) {
        await backup.copy(plain.path);
      }
      if (await enc.exists()) await enc.delete();
      rethrow;
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
