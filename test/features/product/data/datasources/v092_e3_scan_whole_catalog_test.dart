import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';

import '../../../../helpers/fake_database.dart';

/// V092-E.3 — Scan the whole catalog, not the first 500.
///
/// Verifies that `getProductByBarcode` and `getProductBySku` go through the
/// DB (not the in-memory page), so items beyond the 500-row pagination
/// threshold are found.
void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl ds;

  setUp(() {
    db = createInMemoryDatabase();
    ds = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
  });

  tearDown(() => db.close());

  /// Seeds [count] products with barcodes BC-00001 … BC-{count} and
  /// SKUs SKU-0001 … SKU-{count}.
  Future<void> seedProducts(int count) async {
    for (var i = 1; i <= count; i++) {
      final sku = 'SKU-${i.toString().padLeft(4, '0')}';
      final barcode = 'BC-${i.toString().padLeft(5, '0')}';
      await ds.insertProduct(
        ProductsCompanion.insert(
          id: IdGenerator.newId(),
          name: 'Product $i',
          price: 100.0,
          sku: Value(sku),
          skuLower: Value(sku.toLowerCase()),
          barcode: Value(barcode),
          barcodeLower: Value(barcode.toLowerCase()),
          stock: const Value(10),
        ),
      );
    }
  }

  group('V092-E.3: DB lookup beyond pagination threshold', () {
    test('getProductByBarcode finds item 501 (beyond 500-row page)', () async {
      await seedProducts(550);

      final barcode = 'BC-00501';
      final product = await ds.getProductByBarcode(barcode);

      expect(product, isNotNull);
      expect(product!.name, 'Product 501');
      expect(product.barcode, barcode);
    });

    test('getProductBySku finds item 550 (last item, beyond page)', () async {
      await seedProducts(550);

      final sku = 'SKU-0550';
      final product = await ds.getProductBySku(sku);

      expect(product, isNotNull);
      expect(product!.name, 'Product 550');
      expect(product.sku, sku);
    });

    test('getProductByBarcode is case-insensitive', () async {
      await seedProducts(5);

      final product = await ds.getProductByBarcode('bc-00001');
      expect(product, isNotNull);
      expect(product!.name, 'Product 1');
    });

    test('getProductBySku is case-insensitive', () async {
      await seedProducts(5);

      final product = await ds.getProductBySku('sku-0003');
      expect(product, isNotNull);
      expect(product!.name, 'Product 3');
    });

    test('getProductByBarcode returns null for non-existent', () async {
      await seedProducts(10);
      expect(await ds.getProductByBarcode('NOT-FOUND'), isNull);
    });

    test('getProductBySku returns null for non-existent', () async {
      await seedProducts(10);
      expect(await ds.getProductBySku('NOT-FOUND'), isNull);
    });

    test('getProductByBarcode returns null for soft-deleted product', () async {
      await seedProducts(5);
      final product = await ds.getProductByBarcode('BC-00001');
      await ds.deleteProduct(product!.id);

      expect(await ds.getProductByBarcode('BC-00001'), isNull);
    });

    test('getProductBySku returns null for inactive product', () async {
      await seedProducts(5);
      final product = await ds.getProductBySku('SKU-0002');
      // Update isActive = false via raw update.
      final id = product!.id;
      await db.customStatement(
        'UPDATE products SET is_active = 0 WHERE id = ?',
        [id],
      );

      expect(await ds.getProductBySku('SKU-0002'), isNull);
    });
  });
}
