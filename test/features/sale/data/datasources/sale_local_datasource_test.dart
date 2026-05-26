import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late SaleLocalDatasourceImpl saleDatasource;
  late ProductLocalDatasourceImpl productDatasource;

  setUp(() {
    db = createInMemoryDatabase();
    saleDatasource = SaleLocalDatasourceImpl(db);
    productDatasource = ProductLocalDatasourceImpl(db);
  });

  tearDown(() => db.close());

  Future<Product> _seedProduct({
    String name = 'Test Product',
    double price = 100.0,
    int stock = 50,
  }) async {
    final id = await productDatasource.insertProduct(
      ProductsCompanion.insert(
        name: name,
        price: price,
        stock: Value(stock),
      ),
    );
    return (await productDatasource.getProductById(id))!;
  }

  group('SaleLocalDatasourceImpl', () {
    test('insertSaleWithItems creates sale with items and deducts stock',
        () async {
      final product = await _seedProduct(stock: 50);
      final cartItem = CartItem(product: product, qty: 3);

      final sale = await saleDatasource.insertSaleWithItems(
        items: [cartItem],
        paymentMethod: 'cash',
        amountReceived: 500,
        changeAmount: 200,
        note: 'test',
      );

      expect(sale.id, isPositive);
      expect(sale.totalAmount, 300.0);
      expect(sale.paymentMethod, 'cash');
      expect(sale.items.length, 1);
      expect(sale.items.first.productName, 'Test Product');
      expect(sale.items.first.qty, 3);
      expect(sale.items.first.subtotal, 300.0);

      final updatedProduct = await productDatasource.getProductById(product.id);
      expect(updatedProduct!.stock, 47);
    });

    test('querySales returns sales within date range', () async {
      final product = await _seedProduct();
      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
      );

      final allSales = await saleDatasource.querySales();
      expect(allSales.length, 1);

      final futureSales = await saleDatasource.querySales(
        from: DateTime.now().add(const Duration(days: 1)),
      );
      expect(futureSales, isEmpty);
    });

    test('querySaleById returns correct sale', () async {
      final product = await _seedProduct();
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'transfer',
      );

      final fetched = await saleDatasource.querySaleById(sale.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, sale.id);
      expect(fetched.paymentMethod, 'transfer');
      expect(fetched.items.length, 1);
    });

    test('querySaleById returns null for non-existent id', () async {
      final result = await saleDatasource.querySaleById(9999);
      expect(result, isNull);
    });

    test('watchRecentSales emits updates', () async {
      final product = await _seedProduct();
      final stream = saleDatasource.watchRecentSales(limit: 5);

      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'card',
      );

      await expectLater(
        stream,
        emitsThrough(
            predicate<List>((list) => list.isNotEmpty)),
      );
    });

    test('watchSales emits updates', () async {
      final product = await _seedProduct();
      final stream = saleDatasource.watchSales();

      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
      );

      await expectLater(
        stream,
        emitsThrough(
            predicate<List>((list) => list.isNotEmpty)),
      );
    });
  });
}
