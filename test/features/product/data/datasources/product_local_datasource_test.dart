import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl datasource;

  setUp(() {
    db = createInMemoryDatabase();
    datasource = ProductLocalDatasourceImpl(db);
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
      expect(product.price, 100.0);
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
      expect(product.price, 200.0);
    });

    test('deleteProduct removes product', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(companion(id: id));

      await datasource.deleteProduct(id);

      final product = await datasource.getProductById(id);
      expect(product, isNull);
    });

    test('getProductByBarcode returns matching product', () async {
      final id = IdGenerator.newId();
      await datasource.insertProduct(
        companion(
          id: id,
          name: 'Cola',
        ).copyWith(barcode: const Value('1234567890123')),
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
  });
}
