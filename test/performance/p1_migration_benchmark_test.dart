// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:promsell_pos_ce/core/database/app_database.dart';

import '../helpers/scaling_fixture.dart';

/// Benchmark for the v31→v32 schema migration (satang dual-write columns).
///
/// The v32 migration adds 32 nullable INTEGER `*_satang` columns across 10
/// money tables and backfills them from existing REAL baht columns. The
/// backfill is the heavy part — it runs an UPDATE per column per table.
///
/// This benchmark seeds a file-backed database at v32, then:
///   1. NULLs all satang columns to simulate pre-migration state.
///   2. Sets `user_version = 31` so Drift sees the DB as needing upgrade.
///   3. Closes and reopens — Drift runs the migration from 31→32.
///   4. Measures wall-clock duration and asserts a duration budget.
///
/// The duration budget is generous for desktop (no SQLCipher overhead) and
/// is intended as a CI trend signal, not a device-accurate SLO.
void main() {
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p1_migration_bench_');
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  /// All satang columns that the v32 migration backfills.
  const satangColumns = <(String, String)>[
    ('products', 'price_satang'),
    ('products', 'cost_satang'),
    ('product_options', 'price_delta_satang'),
    ('sales', 'subtotal_amount_satang'),
    ('sales', 'discount_amount_satang'),
    ('sales', 'total_amount_satang'),
    ('sales', 'vat_amount_satang'),
    ('sales', 'service_charge_amount_satang'),
    ('sales', 'promotion_discount_amount_satang'),
    ('sales', 'amount_received_satang'),
    ('sales', 'change_amount_satang'),
    ('sale_items', 'price_satang'),
    ('sale_items', 'discount_amount_satang'),
    ('sale_items', 'vat_amount_satang'),
    ('sale_items', 'subtotal_satang'),
    ('sale_payments', 'amount_satang'),
    ('daily_closes', 'opening_cash_satang'),
    ('daily_closes', 'expected_cash_satang'),
    ('daily_closes', 'counted_cash_satang'),
    ('daily_closes', 'over_short_amount_satang'),
    ('daily_closes', 'total_revenue_satang'),
    ('daily_closes', 'total_void_satang'),
    ('daily_closes', 'vat_amount_satang'),
    ('daily_closes', 'discount_amount_satang'),
    ('customers', 'total_spent_satang'),
    ('promotions', 'min_purchase_amount_satang'),
    ('draft_carts', 'promotion_discount_amount_satang'),
    ('draft_cart_items', 'price_satang'),
    // Conditional columns
    ('sales', 'discount_value_satang'),
    ('promotions', 'value_satang'),
    ('draft_carts', 'cart_discount_value_satang'),
    ('draft_cart_items', 'discount_value_satang'),
  ];

  Future<void> nullAllSatangColumns(AppDatabase db) async {
    for (final (table, col) in satangColumns) {
      await db.customStatement('UPDATE $table SET $col = NULL');
    }
  }

  Future<int> countNullSatang(AppDatabase db, String table, String col) async {
    final result = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table WHERE $col IS NULL')
        .getSingle();
    return result.read<int>('c');
  }

  group('P1-1: migration v31→v32 benchmark', () {
    test(
      '50K sales migration completes within duration budget',
      () async {
        // 1. Seed at v32 (fast — scaling fixture creates at current schema).
        final file = File(p.join(tempDir.path, 'migration_50k.db'));
        if (file.existsSync()) file.deleteSync();
        var db = AppDatabase.forTesting(NativeDatabase(file));

        final seedSw = Stopwatch()..start();
        final counts = await seedScalingFixture(
          db,
          productCount: 2000,
          saleCount: 50000,
          saleItemCount: 250000,
          inventoryLogCount: 150000,
        );
        print('  Seeded $counts in ${seedSw.elapsedMilliseconds}ms');

        // 2. Simulate pre-v31 state: NULL all satang columns, set user_version=31.
        await nullAllSatangColumns(db);
        await db.customStatement('PRAGMA user_version = 31');
        await db.close();

        // 3. Reopen — Drift sees user_version=31, runs migration to 32.
        final migrateSw = Stopwatch()..start();
        db = AppDatabase.forTesting(NativeDatabase(file));
        // Force migration to run by accessing the database.
        await db.customSelect('SELECT COUNT(*) AS c FROM sales').getSingle();
        final migrateMs = migrateSw.elapsedMilliseconds;
        print('  v31→v32 migration: ${migrateMs}ms (50k sales, 250k items)');

        // 4. Verify backfill worked — satang columns should be populated.
        final nullPriceSatang = await countNullSatang(
          db,
          'products',
          'price_satang',
        );
        expect(
          nullPriceSatang,
          0,
          reason: 'products.price_satang not backfilled',
        );
        final nullTotalSatang = await countNullSatang(
          db,
          'sales',
          'total_amount_satang',
        );
        expect(
          nullTotalSatang,
          0,
          reason: 'sales.total_amount_satang not backfilled',
        );
        final nullSubtotalSatang = await countNullSatang(
          db,
          'sale_items',
          'subtotal_satang',
        );
        expect(
          nullSubtotalSatang,
          0,
          reason: 'sale_items.subtotal_satang not backfilled',
        );

        // 5. Duration budget: 60s on desktop (generous; device will be slower).
        //    The budget is a CI trend signal, not a device SLO.
        const migrationBudgetMs = 60000;
        expect(
          migrateMs,
          lessThan(migrationBudgetMs),
          reason: 'v31→v32 migration exceeded ${migrationBudgetMs}ms budget',
        );
        print('  Budget: ${migrationBudgetMs}ms — PASS');

        await db.close();
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      '100K sales migration completes within duration budget',
      () async {
        final file = File(p.join(tempDir.path, 'migration_100k.db'));
        if (file.existsSync()) file.deleteSync();
        var db = AppDatabase.forTesting(NativeDatabase(file));

        final seedSw = Stopwatch()..start();
        final counts = await seedScalingFixture(
          db,
          productCount: 2000,
          saleCount: 100000,
          saleItemCount: 500000,
          inventoryLogCount: 300000,
        );
        print('  Seeded $counts in ${seedSw.elapsedMilliseconds}ms');

        await nullAllSatangColumns(db);
        await db.customStatement('PRAGMA user_version = 31');
        await db.close();

        final migrateSw = Stopwatch()..start();
        db = AppDatabase.forTesting(NativeDatabase(file));
        await db.customSelect('SELECT COUNT(*) AS c FROM sales').getSingle();
        final migrateMs = migrateSw.elapsedMilliseconds;
        print('  v31→v32 migration: ${migrateMs}ms (100k sales, 500k items)');

        // Verify backfill.
        final nullTotalSatang = await countNullSatang(
          db,
          'sales',
          'total_amount_satang',
        );
        expect(nullTotalSatang, 0);
        final nullSubtotalSatang = await countNullSatang(
          db,
          'sale_items',
          'subtotal_satang',
        );
        expect(nullSubtotalSatang, 0);

        // Duration budget: 120s on desktop for 100k sales (2x the 50k budget).
        const migrationBudgetMs = 120000;
        expect(
          migrateMs,
          lessThan(migrationBudgetMs),
          reason: 'v31→v32 migration exceeded ${migrationBudgetMs}ms budget',
        );
        print('  Budget: ${migrationBudgetMs}ms — PASS');

        await db.close();
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    test(
      'migration is idempotent — re-running on v32 is a no-op',
      () async {
        final file = File(p.join(tempDir.path, 'migration_idempotent.db'));
        if (file.existsSync()) file.deleteSync();
        var db = AppDatabase.forTesting(NativeDatabase(file));

        await seedScalingFixture(
          db,
          productCount: 100,
          saleCount: 1000,
          saleItemCount: 3000,
          inventoryLogCount: 600,
        );
        await db.close();

        // Reopen at v32 — no migration should run.
        final sw = Stopwatch()..start();
        db = AppDatabase.forTesting(NativeDatabase(file));
        await db.customSelect('SELECT COUNT(*) AS c FROM sales').getSingle();
        final reopenMs = sw.elapsedMilliseconds;
        print('  Reopen at v32 (no migration): ${reopenMs}ms');

        // Should be very fast since no migration runs.
        expect(
          reopenMs,
          lessThan(5000),
          reason: 'reopen should not trigger migration',
        );

        await db.close();
      },
      timeout: const Timeout(Duration(minutes: 3)),
    );
  });
}
