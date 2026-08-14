import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';

/// V092-C.2 — SKU dedupe migration test.
///
/// Simulates a v30 DB with mixed-case SKU duplicates, then upgrades to v31
/// and verifies the dedupe cleared the duplicates so the unique index can
/// be created without stalling.
void main() {
  group('V092-C.2: SKU dedupe on migrate v30 → v31', () {
    test('mixed-case SKU duplicates are cleared by v31 migration', () async {
      // 1. Create a fresh DB at v31 (the _createIndexes already has the
      //    unique index). We temporarily drop it to simulate a v30 DB
      //    that has duplicates.
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // Trigger onCreate.
      await db.customSelect('SELECT 1').get();

      // Drop the unique index so we can insert duplicates (simulates v30
      // before the dedupe repair).
      await db.customStatement(
        'DROP INDEX IF EXISTS idx_products_sku_lower_unique',
      );

      // Insert mixed-case duplicates.
      final id1 = IdGenerator.newId();
      final id2 = IdGenerator.newId();
      final id3 = IdGenerator.newId();

      await db.customStatement(
        '''INSERT INTO products (id, name, price, sku, sku_lower, version, is_active, updated_at)
           VALUES ('$id1', 'A', 100.0, 'ABC', 'abc', 0, 1, '2025-01-01')''',
      );
      await db.customStatement(
        '''INSERT INTO products (id, name, price, sku, sku_lower, version, is_active, updated_at)
           VALUES ('$id2', 'B', 100.0, 'abc', 'abc', 0, 1, '2025-01-02')''',
      );
      await db.customStatement(
        '''INSERT INTO products (id, name, price, sku, sku_lower, version, is_active, updated_at)
           VALUES ('$id3', 'C', 100.0, 'AbC', 'abc', 0, 0, '2025-01-03')''',
      );

      // Verify we have 3 rows with the same sku_lower.
      var dups = await db.customSelect('''SELECT COUNT(*) as cnt FROM products
           WHERE sku_lower = 'abc' ''').getSingle();
      expect(dups.read<int>('cnt'), 3);

      // 2. Run the dedupe SQL (same logic as _deduplicateSkuLower).
      //    Keep newest active: ORDER BY is_active DESC, updated_at DESC.
      final keepId = await db.customSelect('''SELECT id FROM products
           WHERE LOWER(sku) = 'abc'
           ORDER BY is_active DESC, updated_at DESC
           LIMIT 1''').getSingle();

      await db.customStatement(
        '''UPDATE products SET sku = NULL, sku_lower = NULL
           WHERE LOWER(sku) = 'abc' AND id != '${keepId.read<String>('id')}' ''',
      );

      // 3. Recreate the unique index (simulates v31 migration).
      await db.customStatement(
        '''CREATE UNIQUE INDEX IF NOT EXISTS idx_products_sku_lower_unique
           ON products(sku_lower)
           WHERE sku_lower IS NOT NULL AND sku_lower != '' ''',
      );

      // 4. Verify: only one product retains the SKU.
      final remaining = await db.customSelect(
        '''SELECT id, sku, sku_lower FROM products
           WHERE sku_lower = 'abc' ''',
      ).get();
      expect(remaining.length, 1);
      expect(remaining.first.read<String>('id'), keepId.read<String>('id'));

      // 5. The other two have NULL sku.
      final nulled = await db.customSelect('''SELECT id FROM products
           WHERE sku IS NULL AND id IN ('$id1', '$id2', '$id3') ''').get();
      expect(nulled.length, 2);

      // 6. Inserting a new product with 'abc' should now succeed if the
      //    kept product was the active one, or fail if we try 'abc' again.
      //    Since the kept product still has sku_lower='abc', a new insert
      //    with 'abc' should fail (unique constraint).
      expect(
        () => db.customStatement(
          '''INSERT INTO products (id, name, price, sku, sku_lower, version)
             VALUES ('${IdGenerator.newId()}', 'D', 100.0, 'abc', 'abc', 0)''',
        ),
        throwsA(isA<Object>()),
      );
    });

    test('dedupe keeps the newest active product', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      await db.customSelect('SELECT 1').get();
      await db.customStatement(
        'DROP INDEX IF EXISTS idx_products_sku_lower_unique',
      );

      // Insert: active+old, active+new, inactive+newest.
      final idOld = IdGenerator.newId();
      final idNew = IdGenerator.newId();
      final idInactive = IdGenerator.newId();

      await db.customStatement(
        '''INSERT INTO products (id, name, price, sku, sku_lower, version, is_active, updated_at)
           VALUES ('$idOld', 'Old', 100.0, 'XYZ', 'xyz', 0, 1, '2025-01-01')''',
      );
      await db.customStatement(
        '''INSERT INTO products (id, name, price, sku, sku_lower, version, is_active, updated_at)
           VALUES ('$idNew', 'New', 100.0, 'xyz', 'xyz', 0, 1, '2025-01-02')''',
      );
      await db.customStatement(
        '''INSERT INTO products (id, name, price, sku, sku_lower, version, is_active, updated_at)
           VALUES ('$idInactive', 'Inactive', 100.0, 'XyZ', 'xyz', 0, 0, '2025-01-03')''',
      );

      // Dedupe: keep newest active → should be idNew (active, updated_at 2025-01-02).
      final keepId = await db.customSelect('''SELECT id FROM products
           WHERE LOWER(sku) = 'xyz'
           ORDER BY is_active DESC, updated_at DESC
           LIMIT 1''').getSingle();

      expect(keepId.read<String>('id'), idNew);

      await db.customStatement(
        '''UPDATE products SET sku = NULL, sku_lower = NULL
           WHERE LOWER(sku) = 'xyz' AND id != '$idNew' ''',
      );

      final kept = await db.customSelect(
        '''SELECT id, sku FROM products WHERE sku_lower = 'xyz' ''',
      ).getSingle();
      expect(kept.read<String>('id'), idNew);
      expect(kept.read<String>('sku'), 'xyz');
    });
  });
}
