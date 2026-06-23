import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Barcode dedup migration (schema v17)', () {
    test('clears duplicate barcodes keeping active + latest updated', () async {
      // Drop unique index to allow inserting duplicates for testing
      await db.customStatement(
        'DROP INDEX IF EXISTS idx_products_barcode_unique',
      );

      await db.customStatement(
        '''INSERT INTO products (id, name, barcode, price, is_active, created_at, updated_at)
           VALUES
           ('p1', 'Product A', '2000012345678', 100.0, 1, 1000, 2000),
           ('p2', 'Product B', '2000012345678', 200.0, 1, 1000, 1000),
           ('p3', 'Product C', '2000012345678', 300.0, 0, 1000, 3000)''',
      );

      // p1 should be kept (active + latest updated_at among active)
      // p2 and p3 should have barcode cleared
      await db.deduplicateBarcodesForTest();

      final p1 = await db
          .customSelect("SELECT barcode FROM products WHERE id = 'p1'")
          .getSingle();
      expect(p1.read<String?>('barcode'), '2000012345678');

      final p2 = await db
          .customSelect("SELECT barcode FROM products WHERE id = 'p2'")
          .getSingle();
      expect(p2.read<String?>('barcode'), isNull);

      final p3 = await db
          .customSelect("SELECT barcode FROM products WHERE id = 'p3'")
          .getSingle();
      expect(p3.read<String?>('barcode'), isNull);
    });

    test('handles 3+ duplicates correctly', () async {
      await db.customStatement(
        'DROP INDEX IF EXISTS idx_products_barcode_unique',
      );

      await db.customStatement(
        '''INSERT INTO products (id, name, barcode, price, is_active, created_at, updated_at)
           VALUES
           ('a1', 'A1', '2000099988877', 10.0, 1, 1000, 5000),
           ('a2', 'A2', '2000099988877', 20.0, 1, 1000, 4000),
           ('a3', 'A3', '2000099988877', 30.0, 1, 1000, 3000),
           ('a4', 'A4', '2000099988877', 40.0, 1, 1000, 2000)''',
      );

      await db.deduplicateBarcodesForTest();

      // Only a1 (latest updated_at) should keep the barcode
      final kept = await db
          .customSelect(
            "SELECT id FROM products WHERE barcode = '2000099988877'",
          )
          .get();
      expect(kept.length, 1);
      expect(kept.first.read<String>('id'), 'a1');
    });

    test('does not affect products with NULL or empty barcodes', () async {
      await db.customStatement(
        'DROP INDEX IF EXISTS idx_products_barcode_unique',
      );

      await db.customStatement(
        '''INSERT INTO products (id, name, barcode, price, is_active, created_at, updated_at)
           VALUES
           ('n1', 'Null BC', NULL, 10.0, 1, 1000, 1000),
           ('n2', 'Empty BC', '', 20.0, 1, 1000, 1000),
           ('n3', 'Unique BC', '2000011112222333', 30.0, 1, 1000, 1000)''',
      );

      await db.deduplicateBarcodesForTest();

      final n1 = await db
          .customSelect("SELECT barcode FROM products WHERE id = 'n1'")
          .getSingle();
      expect(n1.read<String?>('barcode'), isNull);

      final n3 = await db
          .customSelect("SELECT barcode FROM products WHERE id = 'n3'")
          .getSingle();
      expect(n3.read<String?>('barcode'), '2000011112222333');
    });

    test('unique index can be created after dedup', () async {
      await db.customStatement(
        'DROP INDEX IF EXISTS idx_products_barcode_unique',
      );

      await db.customStatement(
        '''INSERT INTO products (id, name, barcode, price, is_active, created_at, updated_at)
           VALUES
           ('d1', 'D1', '2000055566677', 10.0, 1, 1000, 2000),
           ('d2', 'D2', '2000055566677', 20.0, 1, 1000, 1000)''',
      );

      await db.deduplicateBarcodesForTest();

      // After dedup, creating the unique index should succeed
      await db.customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_products_barcode_unique ON products (barcode)',
      );

      final count = await db
          .customSelect(
            "SELECT COUNT(*) as cnt FROM products WHERE barcode = '2000055566677'",
          )
          .getSingle();
      expect(count.read<int>('cnt'), 1);
    });
  });
}
