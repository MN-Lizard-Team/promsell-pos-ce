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
}
