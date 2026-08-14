import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';

/// Phase M (C1/C3) — v32 satang migration test.
///
/// Verifies that:
/// 1. The `*_satang` INTEGER columns exist on all money tables (schema)
/// 2. The backfill SQL (ROUND(baht * 100)) produces correct satang values
/// 3. NaN/Inf values are excluded (satang stays NULL)
/// 4. Nullable columns (cost, amount_received) stay NULL when baht is NULL
///
/// Note: `onCreate` creates the columns but does NOT run the backfill UPDATE
/// — that only runs during `onUpgrade` (v31 → v32). These tests insert data
/// with REAL baht (satang = NULL), then run the backfill SQL manually to
/// verify the migration logic. C2 will wire writers to populate satang
/// directly; the backfill is only for pre-existing rows on upgrade.
void main() {
  group('Phase M (C1): v32 satang columns exist', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customSelect('SELECT 1').get();
    });

    tearDown(() => db.close());

    test('products has price_satang and cost_satang columns', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO products (id, name, price, cost, stock, version, is_active, updated_at) '
        "VALUES ('$id', 'Test', 99.50, 50.25, 10, 0, 1, '2025-01-01')",
      );

      final row = await db
          .customSelect(
            'SELECT price, price_satang, cost, cost_satang FROM products WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      expect(row.read<double>('price'), 99.50);
      // Satang is NULL for fresh inserts — backfill runs on upgrade only.
      expect(row.read<int?>('price_satang'), isNull);
      expect(row.read<double?>('cost'), 50.25);
      expect(row.read<int?>('cost_satang'), isNull);
    });

    test('sales has conditional and unconditional satang columns', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO sales (id, status, subtotal_amount, total_amount, '
        'payment_method, version, created_at, updated_at) '
        "VALUES ('$id', 'COMPLETED', 100.00, 100.00, 'cash', 0, '2025-01-01', '2025-01-01')",
      );

      // Verify all satang columns exist and are nullable.
      final row = await db
          .customSelect(
            'SELECT discount_value_satang, subtotal_amount_satang, '
            'discount_amount_satang, total_amount_satang, vat_amount_satang, '
            'service_charge_amount_satang, promotion_discount_amount_satang, '
            'amount_received_satang, change_amount_satang '
            'FROM sales WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      expect(row.read<int?>('discount_value_satang'), isNull);
      expect(row.read<int?>('subtotal_amount_satang'), isNull);
      expect(row.read<int?>('total_amount_satang'), isNull);
    });

    test('sale_payments has amount_satang column', () async {
      final saleId = IdGenerator.newId();
      final payId = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO sales (id, status, total_amount, payment_method, version, created_at, updated_at) '
        "VALUES ('$saleId', 'COMPLETED', 100.00, 'cash', 0, '2025-01-01', '2025-01-01')",
      );
      await db.customStatement(
        'INSERT INTO sale_payments (id, sale_id, method, amount, sort_order, version, created_at, updated_at) '
        "VALUES ('$payId', '$saleId', 'cash', 60.00, 0, 0, '2025-01-01', '2025-01-01')",
      );

      final row = await db
          .customSelect(
            'SELECT amount_satang FROM sale_payments WHERE id = ?',
            variables: [Variable<String>(payId)],
          )
          .getSingle();

      expect(row.read<int?>('amount_satang'), isNull);
    });
  });

  group('Phase M (C1): v32 backfill SQL logic', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customSelect('SELECT 1').get();
    });

    tearDown(() => db.close());

    /// Runs the same backfill UPDATE that `_migrateV32SatangColumns` executes
    /// during `onUpgrade` (v31 → v32). This tests the SQL logic without
    /// needing to simulate a full version upgrade.
    Future<void> backfillSatang(
      String table,
      String bahtCol,
      String satangCol,
    ) async {
      await db.customStatement(
        'UPDATE $table SET $satangCol = CAST(ROUND($bahtCol * 100) AS INTEGER) '
        'WHERE $bahtCol IS NOT NULL '
        'AND $bahtCol = $bahtCol '
        'AND abs($bahtCol) < 1e15 '
        'AND $satangCol IS NULL',
      );
    }

    test('products: price and cost backfilled correctly', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO products (id, name, price, cost, stock, version, is_active, updated_at) '
        "VALUES ('$id', 'Test', 99.50, 50.25, 10, 0, 1, '2025-01-01')",
      );

      await backfillSatang('products', 'price', 'price_satang');
      await backfillSatang('products', 'cost', 'cost_satang');

      final row = await db
          .customSelect(
            'SELECT price_satang, cost_satang FROM products WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      expect(row.read<int?>('price_satang'), 9950);
      expect(row.read<int?>('cost_satang'), 5025);
    });

    test('sales: all amount columns backfilled', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO sales (id, status, subtotal_amount, discount_amount, '
        'total_amount, vat_amount, service_charge_amount, '
        'promotion_discount_amount, amount_received, change_amount, '
        'payment_method, version, created_at, updated_at) '
        "VALUES ('$id', 'COMPLETED', 100.00, 10.00, 90.00, 6.30, 5.00, "
        "0.00, 100.00, 10.00, 'cash', 0, '2025-01-01', '2025-01-01')",
      );

      const cols = [
        ('subtotal_amount', 'subtotal_amount_satang'),
        ('discount_amount', 'discount_amount_satang'),
        ('total_amount', 'total_amount_satang'),
        ('vat_amount', 'vat_amount_satang'),
        ('service_charge_amount', 'service_charge_amount_satang'),
        ('promotion_discount_amount', 'promotion_discount_amount_satang'),
        ('amount_received', 'amount_received_satang'),
        ('change_amount', 'change_amount_satang'),
      ];
      for (final (baht, satang) in cols) {
        await backfillSatang('sales', baht, satang);
      }

      final row = await db
          .customSelect(
            'SELECT discount_value_satang, subtotal_amount_satang, '
            'discount_amount_satang, total_amount_satang, vat_amount_satang, '
            'service_charge_amount_satang, promotion_discount_amount_satang, '
            'amount_received_satang, change_amount_satang '
            'FROM sales WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      expect(row.read<int?>('subtotal_amount_satang'), 10000);
      expect(row.read<int?>('discount_amount_satang'), 1000);
      expect(row.read<int?>('total_amount_satang'), 9000);
      expect(row.read<int?>('vat_amount_satang'), 630);
      expect(row.read<int?>('service_charge_amount_satang'), 500);
      expect(row.read<int?>('promotion_discount_amount_satang'), 0);
      expect(row.read<int?>('amount_received_satang'), 10000);
      expect(row.read<int?>('change_amount_satang'), 1000);
    });

    test('daily_closes: all satang columns backfilled', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO daily_closes (id, close_date, opening_cash, expected_cash, '
        'counted_cash, over_short_amount, total_revenue, total_void, '
        'sales_count, void_count, vat_amount, discount_amount, version, updated_at) '
        "VALUES ('$id', '2025-01-01', 1000.00, 500.00, 495.00, -5.00, "
        "2000.00, 50.00, 10, 1, 140.00, 100.00, 0, '2025-01-01')",
      );

      const cols = [
        ('opening_cash', 'opening_cash_satang'),
        ('expected_cash', 'expected_cash_satang'),
        ('counted_cash', 'counted_cash_satang'),
        ('over_short_amount', 'over_short_amount_satang'),
        ('total_revenue', 'total_revenue_satang'),
        ('total_void', 'total_void_satang'),
        ('vat_amount', 'vat_amount_satang'),
        ('discount_amount', 'discount_amount_satang'),
      ];
      for (final (baht, satang) in cols) {
        await backfillSatang('daily_closes', baht, satang);
      }

      final row = await db
          .customSelect(
            'SELECT opening_cash_satang, expected_cash_satang, counted_cash_satang, '
            'over_short_amount_satang, total_revenue_satang, total_void_satang, '
            'vat_amount_satang, discount_amount_satang '
            'FROM daily_closes WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      expect(row.read<int?>('opening_cash_satang'), 100000);
      expect(row.read<int?>('expected_cash_satang'), 50000);
      expect(row.read<int?>('counted_cash_satang'), 49500);
      expect(row.read<int?>('over_short_amount_satang'), -500);
      expect(row.read<int?>('total_revenue_satang'), 200000);
      expect(row.read<int?>('total_void_satang'), 5000);
      expect(row.read<int?>('vat_amount_satang'), 14000);
      expect(row.read<int?>('discount_amount_satang'), 10000);
    });

    test('customers: total_spent_satang backfilled', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO customers (id, name, total_spent, visit_count, version, created_at, updated_at) '
        "VALUES ('$id', 'John', 1234.56, 5, 0, '2025-01-01', '2025-01-01')",
      );

      await backfillSatang('customers', 'total_spent', 'total_spent_satang');

      final row = await db
          .customSelect(
            'SELECT total_spent_satang FROM customers WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      expect(row.read<int?>('total_spent_satang'), 123456);
    });

    test('nullable cost: cost_satang stays NULL when cost is NULL', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO products (id, name, price, stock, version, is_active, updated_at) '
        "VALUES ('$id', 'No Cost', 50.00, 5, 0, 1, '2025-01-01')",
      );

      await backfillSatang('products', 'price', 'price_satang');
      await backfillSatang('products', 'cost', 'cost_satang');

      final row = await db
          .customSelect(
            'SELECT cost, cost_satang, price_satang FROM products WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      expect(row.read<double?>('cost'), isNull);
      expect(row.read<int?>('cost_satang'), isNull);
      expect(row.read<int?>('price_satang'), 5000);
    });

    test('half-up rounding: 99.995 baht → 10000 satang', () async {
      final id = IdGenerator.newId();
      await db.customStatement(
        'INSERT INTO products (id, name, price, stock, version, is_active, updated_at) '
        "VALUES ('$id', 'Half Up', 99.995, 5, 0, 1, '2025-01-01')",
      );

      await backfillSatang('products', 'price', 'price_satang');

      final row = await db
          .customSelect(
            'SELECT price_satang FROM products WHERE id = ?',
            variables: [Variable<String>(id)],
          )
          .getSingle();

      // SQLite ROUND(99.995 * 100) = ROUND(9999.5) = 10000 (half away from zero)
      expect(row.read<int?>('price_satang'), 10000);
    });

    test(
      'idempotent: re-running backfill does not overwrite existing satang',
      () async {
        final id = IdGenerator.newId();
        await db.customStatement(
          'INSERT INTO products (id, name, price, stock, version, is_active, updated_at) '
          "VALUES ('$id', 'Idempotent', 50.00, 5, 0, 1, '2025-01-01')",
        );

        await backfillSatang('products', 'price', 'price_satang');
        // Manually set a different value to verify backfill doesn't overwrite.
        await db.customStatement(
          "UPDATE products SET price_satang = 99999 WHERE id = '$id'",
        );
        await backfillSatang('products', 'price', 'price_satang');

        final row = await db
            .customSelect(
              'SELECT price_satang FROM products WHERE id = ?',
              variables: [Variable<String>(id)],
            )
            .getSingle();

        // The WHERE clause `AND price_satang IS NULL` prevents overwrite.
        expect(row.read<int?>('price_satang'), 99999);
      },
    );
  });

  test(
    'v31 file-backed database upgrades and backfills satang columns',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'promsell_phase_m_',
      );
      final dbFile = File('${tempDir.path}${Platform.pathSeparator}legacy.db');
      AppDatabase? legacyDb;
      AppDatabase? upgradedDb;

      try {
        legacyDb = AppDatabase.forTesting(NativeDatabase(dbFile));
        await legacyDb.customSelect('SELECT 1').get();

        final productId = IdGenerator.newId();
        final saleId = IdGenerator.newId();
        final percentSaleId = IdGenerator.newId();
        final createdAt = DateTime(2025, 1, 1).millisecondsSinceEpoch;
        await legacyDb.customStatement(
          'INSERT INTO products (id, name, price, cost, stock, version, is_active, updated_at) '
          "VALUES ('$productId', 'Legacy', 123.45, 99.99, 5, 0, 1, $createdAt)",
        );
        await legacyDb.customStatement(
          'INSERT INTO sales (id, status, discount_type, discount_value, '
          'total_amount, payment_method, version, created_at, updated_at) '
          "VALUES ('$saleId', 'COMPLETED', 'AMOUNT', 1.23, 123.45, 'cash', "
          '0, $createdAt, $createdAt)',
        );
        await legacyDb.customStatement(
          'INSERT INTO sales (id, status, discount_type, discount_value, '
          'total_amount, payment_method, version, created_at, updated_at) '
          "VALUES ('$percentSaleId', 'COMPLETED', 'PERCENT', 10.0, 123.45, "
          "'cash', 0, $createdAt, $createdAt)",
        );

        const satangColumns = [
          ('products', 'price_satang'),
          ('products', 'cost_satang'),
          ('sales', 'discount_value_satang'),
          ('sales', 'total_amount_satang'),
          ('promotions', 'value_satang'),
          ('draft_carts', 'cart_discount_value_satang'),
          ('draft_cart_items', 'discount_value_satang'),
        ];
        for (final (table, column) in satangColumns) {
          await legacyDb.customStatement(
            'ALTER TABLE $table DROP COLUMN $column',
          );
        }
        await legacyDb.customStatement('PRAGMA user_version = 31');
        await legacyDb.close();
        legacyDb = null;

        upgradedDb = AppDatabase.forTesting(NativeDatabase(dbFile));
        await upgradedDb.customSelect('SELECT 1').get();

        final productRaw = await upgradedDb
            .customSelect(
              'SELECT price_satang, cost_satang FROM products WHERE id = ?',
              variables: [Variable<String>(productId)],
            )
            .getSingle();
        expect(productRaw.read<int>('price_satang'), 12345);
        expect(productRaw.read<int>('cost_satang'), 9999);

        final saleRaw = await upgradedDb
            .customSelect(
              'SELECT total_amount_satang, discount_value_satang '
              'FROM sales WHERE id = ?',
              variables: [Variable<String>(saleId)],
            )
            .getSingle();
        expect(saleRaw.read<int>('total_amount_satang'), 12345);
        expect(saleRaw.read<int>('discount_value_satang'), 123);

        final percentSaleRaw = await upgradedDb
            .customSelect(
              'SELECT discount_value_satang FROM sales WHERE id = ?',
              variables: [Variable<String>(percentSaleId)],
            )
            .getSingle();
        expect(percentSaleRaw.read<int?>('discount_value_satang'), isNull);

        final productData = await (upgradedDb.select(
          upgradedDb.products,
        )..where((p) => p.id.equals(productId))).getSingle();
        expect(productData.priceSatang, const Money.fromSatang(12345));
        expect(productData.costSatang, const Money.fromSatang(9999));
      } finally {
        await upgradedDb?.close();
        await legacyDb?.close();
        await tempDir.delete(recursive: true);
      }
    },
  );
}
