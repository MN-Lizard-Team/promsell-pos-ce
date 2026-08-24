import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';

/// V092-C.2 + V092-C.3 — Migration hygiene tests.
///
/// C.2: SKU dedupe before unique index (v31) — verifies the unique index
/// exists and prevents case-insensitive duplicates.
/// C.3: idempotent index/trigger set — verifies triggers exist on fresh DB.
void main() {
  group('V092-C.2: SKU unique index', () {
    test('sku_lower unique index exists on fresh DB', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();

      final indexes = await db.customSelect(
        '''SELECT name FROM sqlite_master
           WHERE type = 'index' AND name = 'idx_products_sku_lower_unique' ''',
      ).get();

      expect(indexes, isNotEmpty);
    });

    test(
      'sku_lower unique index prevents case-insensitive duplicates',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await db.customSelect('SELECT 1').get();

        await db.customStatement(
          '''INSERT INTO products (id, name, price, sku, sku_lower, version)
           VALUES ('${IdGenerator.newId()}', 'A', 100.0, 'ABC', 'abc', 0)''',
        );

        expect(
          () => db.customStatement(
            '''INSERT INTO products (id, name, price, sku, sku_lower, version)
             VALUES ('${IdGenerator.newId()}', 'B', 100.0, 'abc', 'abc', 0)''',
          ),
          throwsA(isA<Object>()),
        );
      },
    );
  });

  group('V092-C.3: idempotent triggers after fresh install', () {
    test('price positive trigger exists', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();

      final triggers = await db.customSelect(
        '''SELECT name FROM sqlite_master
           WHERE type = 'trigger' AND name = 'chk_products_price_positive' ''',
      ).get();

      expect(triggers, isNotEmpty);
    });

    test('price positive update trigger exists', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();

      final triggers = await db.customSelect('''SELECT name FROM sqlite_master
           WHERE type = 'trigger'
           AND name = 'chk_products_price_positive_update' ''').get();

      expect(triggers, isNotEmpty);
    });

    test('cost non-negative trigger exists', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();

      final triggers = await db.customSelect(
        '''SELECT name FROM sqlite_master
           WHERE type = 'trigger' AND name = 'chk_products_cost_nonneg' ''',
      ).get();

      expect(triggers, isNotEmpty);
    });

    test('barcode_lower unique index exists', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();

      final indexes = await db.customSelect('''SELECT name FROM sqlite_master
           WHERE type = 'index'
           AND name = 'idx_products_barcode_lower_unique' ''').get();

      expect(indexes, isNotEmpty);
    });
  });

  group('P1 scaling: inventory_logs composite index', () {
    test(
      'idx_inventory_logs_product_id_created_at exists on fresh DB',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);

        await db.customSelect('SELECT 1').get();

        final indexes = await db.customSelect('''SELECT name FROM sqlite_master
           WHERE type = 'index'
           AND name = 'idx_inventory_logs_product_id_created_at' ''').get();

        expect(indexes, isNotEmpty);
      },
    );

    test('composite index covers per-product ORDER BY created_at DESC', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();

      // Insert logs for two products with different timestamps.
      final now = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < 5; i++) {
        await db.customStatement(
          'INSERT INTO inventory_logs '
          '(id, product_id, type, qty_change, balance_after, reason, created_at, version) '
          "VALUES ('log-$i', 'prod-A', 'ADJUSTMENT_IN', 1, ${i + 1}, 'test', $now, 0)",
        );
      }
      for (var i = 0; i < 3; i++) {
        await db.customStatement(
          'INSERT INTO inventory_logs '
          '(id, product_id, type, qty_change, balance_after, reason, created_at, version) '
          "VALUES ('logb-$i', 'prod-B', 'SALE', -1, ${10 - i}, null, $now, 0)",
        );
      }

      // Query plan should use the composite index, not a full scan.
      final plan = await db
          .customSelect(
            'EXPLAIN QUERY PLAN '
            'SELECT * FROM inventory_logs '
            "WHERE product_id = 'prod-A' AND deleted_at IS NULL "
            'ORDER BY created_at DESC LIMIT 200',
          )
          .get();

      final planText = plan.map((r) => r.data['detail'] as String).join('\n');
      expect(
        planText,
        contains('idx_inventory_logs_product_id_created_at'),
        reason:
            'Query plan should use the composite index, not a full scan.\n'
            'Plan: $planText',
      );
    });
  });
}
