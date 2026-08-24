// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';

import '../../helpers/scaling_fixture.dart';

/// Regression test for the v10 daily_closes rebuild landmine.
///
/// A database upgrading from schema v9 reaches the `from < 10` step with a
/// 16-column daily_closes (13 base columns + payment_breakdown/vat_amount/
/// discount_amount added by the `from < 9` step), while today's DailyCloses
/// has 27 columns in a different order. The old `INSERT ... SELECT *` copy
/// failed with "table daily_closes has 27 columns but N values were supplied"
/// and crashed every launch until reinstall; the fixed copy names columns
/// explicitly. This test replays the exact v9 -> v32 upgrade path and asserts
/// the rebuild preserves legacy rows.
///
/// Simulation approach (mirrors phase_m_v32_satang_migration_test): open a
/// fresh AppDatabase.forTesting(NativeDatabase(file)) so all tables exist at
/// today's shape, then rewind to a faithful v9 state — drop tables that did
/// not exist at v9 and recreate daily_closes with its exact v9-era shape and
/// seeded rows. Simplification: surviving base tables keep post-v9 columns;
/// every later step adds columns via addColumnIfNotExists / IF NOT EXISTS, so
/// extra columns are inert — only daily_closes was position-sensitive because
/// of the rebuild copy.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('pre_v10_migration_');
    // Backs MigrationSafetyService status-file writes made during reopen.
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// Exact v9-era daily_closes definition: the 13 base columns as of v7
  /// (last pre-v10 released shape) plus the three columns the `from < 9`
  /// block guarantees before the rebuild runs. Column ORDER matters here —
  /// the three added columns sit AFTER device_id, unlike today's layout.
  const v9CreateDailyCloses = '''
    CREATE TABLE daily_closes (
      id TEXT NOT NULL PRIMARY KEY,
      close_date TEXT NOT NULL,
      opening_cash REAL NOT NULL DEFAULT 0.0,
      expected_cash REAL NOT NULL DEFAULT 0.0,
      counted_cash REAL NOT NULL DEFAULT 0.0,
      over_short_amount REAL NOT NULL DEFAULT 0.0,
      total_revenue REAL NOT NULL DEFAULT 0.0,
      total_void REAL NOT NULL DEFAULT 0.0,
      sales_count INTEGER NOT NULL DEFAULT 0,
      void_count INTEGER NOT NULL DEFAULT 0,
      note TEXT NULL,
      closed_at INTEGER NOT NULL,
      device_id TEXT NULL,
      payment_breakdown TEXT NOT NULL DEFAULT '{}',
      vat_amount REAL NOT NULL DEFAULT 0.0,
      discount_amount REAL NOT NULL DEFAULT 0.0
    )
  ''';

  /// The v9-era column list used by the fixed named-column copy.
  const v9Columns =
      'id, close_date, opening_cash, expected_cash, counted_cash, '
      'over_short_amount, total_revenue, total_void, sales_count, void_count, '
      'payment_breakdown, vat_amount, discount_amount, note, closed_at, '
      'device_id';

  /// Tables absent at v9 that the chain recreates (v20/v21/v28 blocks) or
  /// intentionally leaves absent (product_audits — never recreated by any
  /// migration step, matching production upgrades).
  const nonV9Tables = [
    'product_audits',
    'restaurant_tables',
    'product_option_groups',
    'product_options',
    'customers',
    'promotions',
    'sale_payments',
  ];

  Future<File> rewindToV9(String dbName) async {
    final dbFile = File(p.join(tempDir.path, dbName));
    if (dbFile.existsSync()) dbFile.deleteSync();

    final fresh = AppDatabase.forTesting(NativeDatabase(dbFile));
    await fresh.customSelect('SELECT 1').get();
    await fresh.close();

    final raw = AppDatabase.forTesting(NativeDatabase(dbFile));
    await raw.customSelect('SELECT 1').get();
    for (final table in nonV9Tables) {
      await raw.customStatement('DROP TABLE IF EXISTS $table');
    }
    await raw.customStatement('ALTER TABLE daily_closes RENAME TO dc_tmp');
    await raw.customStatement('DROP TABLE dc_tmp');
    await raw.customStatement(v9CreateDailyCloses);

    // Two legacy rows, values listed in v9-era column order. Real v9 rows
    // always had a non-NULL closed_at (the column was NOT NULL back then);
    // NULL handling is asserted post-upgrade instead.
    await raw.customStatement('''
      INSERT INTO daily_closes (
        id, close_date, opening_cash, expected_cash, counted_cash,
        over_short_amount, total_revenue, total_void, sales_count, void_count,
        note, closed_at, device_id,
        payment_breakdown, vat_amount, discount_amount
      ) VALUES (
        'dc-closed', '2025-01-14', 1000.0, 1050.5, 1048.25,
        -2.25, 8000.0, 250.0, 12, 1,
        'shift ok', 1736868000, 'dev-legacy',
        '{"cash":1048.25}', 560.0, 40.0
      )
    ''');
    await raw.customStatement('''
      INSERT INTO daily_closes (
        id, close_date, opening_cash, expected_cash, counted_cash,
        over_short_amount, total_revenue, total_void, sales_count, void_count,
        note, closed_at, device_id,
        payment_breakdown, vat_amount, discount_amount
      ) VALUES (
        'dc-open', '2025-01-15', 500.0, 600.0, 600.0,
        0.0, 1500.0, 0.0, 3, 0,
        NULL, 1736954400, NULL,
        '{}', 105.0, 0.0
      )
    ''');

    await raw.customStatement('PRAGMA user_version = 9');
    await raw.close();
    return dbFile;
  }

  test('v9-shaped database upgrades through the v10 rebuild to v32 '
      'with daily_closes rows preserved', () async {
    final dbFile = await rewindToV9('pre_v10_upgrade.db');

    // Reopen triggers the 9 -> 32 onUpgrade chain. Any exception here is
    // the crash loop this test exists to prevent.
    final db = AppDatabase.forTesting(NativeDatabase(dbFile));
    try {
      await db.customSelect('SELECT 1').get();

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 32);

      // The rebuild left no shadow table behind.
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name LIKE 'daily_closes%'",
          )
          .get();
      expect(tables.map((r) => r.read<String>('name')), ['daily_closes']);

      // Upgraded table carries the full modern 27-column shape.
      final columnCount = await db
          .customSelect(
            "SELECT COUNT(*) AS c FROM pragma_table_info('daily_closes')",
          )
          .getSingle();
      expect(columnCount.read<int>('c'), 27);

      // Legacy rows survived the rebuild with every v9-era value landing
      // in the correctly NAMED column (a positional copy would scramble
      // payment_breakdown/vat_amount/discount_amount into other columns).
      final closed = await db
          .customSelect(
            'SELECT $v9Columns FROM daily_closes WHERE id = ?',
            variables: [const Variable<String>('dc-closed')],
          )
          .getSingle();
      expect(closed.read<String>('close_date'), '2025-01-14');
      expect(closed.read<double>('opening_cash'), 1000.0);
      expect(closed.read<double>('expected_cash'), 1050.5);
      expect(closed.read<double>('counted_cash'), 1048.25);
      expect(closed.read<double>('over_short_amount'), -2.25);
      expect(closed.read<double>('total_revenue'), 8000.0);
      expect(closed.read<double>('total_void'), 250.0);
      expect(closed.read<int>('sales_count'), 12);
      expect(closed.read<int>('void_count'), 1);
      expect(closed.read<String>('payment_breakdown'), '{"cash":1048.25}');
      expect(closed.read<double>('vat_amount'), 560.0);
      expect(closed.read<double>('discount_amount'), 40.0);
      expect(closed.read<String>('note'), 'shift ok');
      expect(closed.read<int>('closed_at'), 1736868000);
      expect(closed.read<String>('device_id'), 'dev-legacy');

      // Columns newer than v10 took their declared defaults.
      final modern = await db
          .customSelect(
            'SELECT updated_at, deleted_at, version, '
            'opening_cash_satang, vat_amount_satang '
            'FROM daily_closes WHERE id = ?',
            variables: [const Variable<String>('dc-closed')],
          )
          .getSingle();
      expect(modern.read<int?>('updated_at'), isNotNull); // v11+v12 backfill
      expect(modern.read<int?>('deleted_at'), isNull);
      expect(modern.read<int>('version'), 1);

      // Satang-era behavior unaffected: v32 backfilled dual-write columns
      // from the preserved REAL baht values (ROUND(baht * 100)).
      expect(modern.read<int?>('opening_cash_satang'), 100000);
      expect(modern.read<int?>('vat_amount_satang'), 56000);

      // The purpose of v10 itself: closed_at is now nullable for NEW rows.
      await db.customStatement('''
          INSERT INTO daily_closes (
            id, close_date, opening_cash, expected_cash, counted_cash,
            over_short_amount, total_revenue, total_void, sales_count,
            void_count, payment_breakdown, vat_amount, discount_amount,
            note, closed_at, device_id
          ) VALUES (
            'dc-null-close', '2025-01-16', 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0,
            0, '{}', 0.0, 0.0,
            NULL, NULL, NULL
          )
        ''');
      final nullClose = await db
          .customSelect(
            'SELECT closed_at FROM daily_closes WHERE id = ?',
            variables: [const Variable<String>('dc-null-close')],
          )
          .getSingle();
      expect(nullClose.read<int?>('closed_at'), isNull);

      // Tables dropped in the rewind were recreated by their own steps.
      final recreated = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' AND name IN "
            "('customers','promotions','restaurant_tables','sale_payments')",
          )
          .get();
      expect(recreated.length, 4);

      // Migration-safety wiring recorded a successful 9 -> 32 run.
      final statusFile = File(p.join(tempDir.path, 'migration_status.json'));
      expect(statusFile.existsSync(), isTrue);
      final status = statusFile.readAsStringSync();
      print('  migration status: $status');
      expect(status, contains('"status":"succeeded"'));
      expect(status, contains('"from":9'));
      expect(status, contains('"to":32'));
    } finally {
      await db.close();
    }
  });

  test(
    'documents why SELECT * fails here: 16 legacy vs 27 modern columns',
    () async {
      // Reproduces the original failure mode in isolation: positionally
      // copying the v9-era shape into today's drift-generated table errors,
      // while the shipped named-column copy succeeds.
      final fresh = AppDatabase.forTesting(NativeDatabase.memory());
      await fresh.customSelect('SELECT 1').get();
      final ddl = await fresh
          .customSelect(
            "SELECT sql FROM sqlite_master WHERE name='daily_closes'",
          )
          .getSingle();
      final modernDdl = ddl.read<String>('sql');
      await fresh.close();

      final sim = AppDatabase.forTesting(NativeDatabase.memory());
      try {
        await sim.customSelect('SELECT 1').get();
        // onCreate already made today's table; swap it for the v9-era shape.
        await sim.customStatement('ALTER TABLE daily_closes RENAME TO dc_tmp');
        await sim.customStatement('DROP TABLE dc_tmp');
        await sim.customStatement(v9CreateDailyCloses);
        await sim.customStatement(
          'ALTER TABLE daily_closes RENAME TO daily_closes_old',
        );
        await sim.customStatement(modernDdl);

        await expectLater(
          sim.customStatement(
            'INSERT INTO daily_closes SELECT * FROM daily_closes_old',
          ),
          throwsA(anything),
        );

        await sim.customStatement(
          'INSERT INTO daily_closes ($v9Columns) '
          'SELECT $v9Columns FROM daily_closes_old',
        );
        final copied = await sim
            .customSelect('SELECT COUNT(*) AS c FROM daily_closes')
            .getSingle();
        expect(copied.read<int>('c'), 0); // empty source copies cleanly
      } finally {
        await sim.close();
      }
    },
  );
}
