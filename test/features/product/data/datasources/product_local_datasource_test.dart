import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl datasource;

  setUp(() {
    db = createInMemoryDatabase();
    datasource = ProductLocalDatasourceImpl(
      db,
      ProductOptionDatasourceImpl(db),
    );
  });

  tearDown(() => db.close());

  ProductsCompanion companion({
    String? id,
    String name = 'Test',
    double price = 100.0,
    int stock = 10,
    String? category,
  }) => ProductsCompanion.insert(
    id: id ?? IdGenerator.newId(),
    name: name,
    price: price,
    stock: Value(stock),
    categoryId: Value(category),
  );

  group('ProductLocalDatasourceImpl', () {
    test('insertProduct inserts and getProductById retrieves it', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(companion(id: id, name: 'Water'));

      final product = await datasource.getProductById(id);
      expect(product, isNotNull);
      expect(product!.name, 'Water');
      expect(product.price, Money.fromDouble(100.0));
      expect(product.stock, 10);
    });

    test('watchAllProducts emits updates', () async {
      final stream = datasource.watchAllProducts();

      await datasource.insertProduct(companion(name: 'A'));

      await expectLater(
        stream,
        emitsThrough(
          predicate<List>((list) => list.isNotEmpty && list.first.name == 'A'),
        ),
      );
    });

    test('getActiveProducts filters inactive products', () async {
      await datasource.insertProduct(companion(name: 'Active'));
      final id2 = IdGenerator.newId();
      await datasource.insertProduct(companion(id: id2, name: 'Inactive'));

      await datasource.updateProduct(
        ProductsCompanion(id: Value(id2), isActive: const Value(false)),
      );

      final activeProducts = await datasource.getActiveProducts();
      expect(activeProducts.length, 1);
      expect(activeProducts.first.name, 'Active');
    });

    test('updateProduct changes fields', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(companion(id: id, name: 'Old'));

      await datasource.updateProduct(
        ProductsCompanion(
          id: Value(id),
          name: const Value('New'),
          price: const Value(200.0),
        ),
      );

      final product = await datasource.getProductById(id);
      expect(product!.name, 'New');
      expect(product.price, Money.fromDouble(200.0));
    });

    test('deleteProduct soft-deletes product (hidden from queries)', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(companion(id: id, name: 'Gone'));

      await datasource.deleteProduct(id);

      // Soft-deleted products are hidden from all active queries.
      expect(await datasource.getProductById(id), isNull);
      expect(
        await datasource.getAllProducts(),
        everyElement(isNot(predicate<Product>((p) => p.id == id))),
      );
      expect(
        await datasource.getActiveProducts(),
        everyElement(isNot(predicate<Product>((p) => p.id == id))),
      );
      // Row still exists in the table (soft-delete, not hard delete).
      final raw = await (db.select(
        db.products,
      )..where((p) => p.id.equals(id))).getSingleOrNull();
      expect(raw, isNotNull);
      expect(raw!.deletedAt, isNotNull);
      expect(raw.isActive, isFalse);
    });

    test('soft-deleted product is excluded from watchAllProducts', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(companion(id: id, name: 'Hidden'));
      await datasource.deleteProduct(id);

      final rows = await datasource.watchAllProducts().first;
      expect(rows, everyElement(isNot(predicate<Product>((p) => p.id == id))));
    });

    test('soft-deleted product is excluded from getProductByBarcode', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(
        companion(
          id: id,
          name: 'Scan',
        ).copyWith(barcode: const Value('SOFTDEL001')),
      );
      await datasource.deleteProduct(id);

      expect(await datasource.getProductByBarcode('SOFTDEL001'), isNull);
    });

    test('getProductByBarcode returns matching product', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(
        companion(id: id, name: 'Cola').copyWith(
          barcode: const Value('1234567890123'),
          barcodeLower: const Value('1234567890123'),
        ),
      );

      final product = await datasource.getProductByBarcode('1234567890123');
      expect(product, isNotNull);
      expect(product!.name, 'Cola');
      expect(product.barcode, '1234567890123');
    });

    test('getProductByBarcode returns null when no match', () async {
      await datasource.insertProduct(companion(name: 'NoBarcode'));

      final product = await datasource.getProductByBarcode('9999999999999');
      expect(product, isNull);
    });

    test(
      'barcodeExistsAnyStatus returns true for matching barcode regardless of isActive',
      () async {
        final id = IdGenerator.newId();
        await datasource.insertProduct(
          companion(id: id, name: 'Cola').copyWith(
            barcode: const Value('1234567890123'),
            barcodeLower: const Value('1234567890123'),
            isActive: const Value(false),
          ),
        );

        expect(
          await datasource.barcodeExistsAnyStatus('1234567890123'),
          isTrue,
        );
      },
    );

    test('barcodeExistsAnyStatus respects excludeId', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(
        companion(id: id, name: 'Cola').copyWith(
          barcode: const Value('1234567890123'),
          barcodeLower: const Value('1234567890123'),
        ),
      );

      expect(
        await datasource.barcodeExistsAnyStatus('1234567890123', excludeId: id),
        isFalse,
      );
      expect(
        await datasource.barcodeExistsAnyStatus(
          '1234567890123',
          excludeId: 'other-id',
        ),
        isTrue,
      );
    });

    test(
      'bulkUpdateBarcodesWithImages updates barcode and barcodeImagePath',
      () async {
        final id = IdGenerator.newId();
        await datasource.insertProduct(companion(id: id, name: 'Tea'));

        await datasource.bulkUpdateBarcodesWithImages([
          (id: id, barcode: 'ABC123', barcodeImagePath: '/path/to/img.png'),
        ]);

        final product = await datasource.getProductById(id);
        expect(product!.barcode, 'ABC123');
        expect(product.barcodeImagePath, '/path/to/img.png');
      },
    );
  });
}
