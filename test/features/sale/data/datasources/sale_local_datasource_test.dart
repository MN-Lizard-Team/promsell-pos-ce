import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late SaleLocalDatasourceImpl saleDatasource;
  late ProductLocalDatasourceImpl productDatasource;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    saleDatasource = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(
        db,
        settingsRepo: fakeSettingsRepo,
      ),
      settingsRepo: fakeSettingsRepo,
    );
    productDatasource = ProductLocalDatasourceImpl(db);
  });

  tearDown(() => db.close());

  Future<Product> seedProduct({
    String name = 'Test Product',
    double price = 100.0,
    int stock = 50,
  }) async {
    final id = IdGenerator.newId();
    await productDatasource.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: name,
        price: price,
        stock: Value(stock),
      ),
    );
    return (await productDatasource.getProductById(id))!;
  }

  group('SaleLocalDatasourceImpl', () {
    test(
      'insertSaleWithItems creates sale with items and deducts stock',
      () async {
        final product = await seedProduct(stock: 50);
        final cartItem = CartItem(product: product, qty: 3);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [cartItem],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: 500,
          changeAmount: 200,
          note: 'test',
        );

        expect(sale.id, isNotEmpty);
        expect(sale.totalAmount, 300.0);
        expect(sale.paymentMethod, 'cash');
        expect(sale.items.length, 1);
        expect(sale.items.first.productName, 'Test Product');
        expect(sale.items.first.qty, 3);
        expect(sale.items.first.subtotal, 300.0);

        final updatedProduct = await productDatasource.getProductById(
          product.id,
        );
        expect(updatedProduct!.stock, 47);
      },
    );

    test('querySales returns sales within date range', () async {
      final product = await seedProduct();
      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      final allSales = await saleDatasource.querySales();
      expect(allSales.length, 1);

      final futureSales = await saleDatasource.querySales(
        from: DateTime.now().add(const Duration(days: 1)),
      );
      expect(futureSales, isEmpty);
    });

    test('querySaleById returns correct sale', () async {
      final product = await seedProduct();
      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'transfer',
        vatMode: 'NONE',
        vatRate: 0,
      );

      final fetched = await saleDatasource.querySaleById(sale.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, sale.id);
      expect(fetched.paymentMethod, 'transfer');
      expect(fetched.items.length, 1);
    });

    test('querySaleById returns null for non-existent id', () async {
      final result = await saleDatasource.querySaleById('non-existent-uuid');
      expect(result, isNull);
    });

    test('watchRecentSales emits updates', () async {
      final product = await seedProduct();
      final stream = saleDatasource.watchRecentSales(limit: 5);

      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'card',
        vatMode: 'NONE',
        vatRate: 0,
      );

      await expectLater(
        stream,
        emitsThrough(predicate<List>((list) => list.isNotEmpty)),
      );
    });

    test('watchSales emits updates', () async {
      final product = await seedProduct();
      final stream = saleDatasource.watchSales();

      await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      await expectLater(
        stream,
        emitsThrough(predicate<List>((list) => list.isNotEmpty)),
      );
    });

    test('insertSaleWithItems preserves discount fields', () async {
      final product = await seedProduct(price: 200.0, stock: 50);
      final cartItem = CartItem(
        product: product,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10.0,
      );

      final sale = await saleDatasource.insertSaleWithItems(
        items: [cartItem],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        cartDiscountType: 'AMOUNT',
        cartDiscountValue: 20.0,
        cartDiscountAmount: 20.0,
      );

      expect(sale.discountType, 'AMOUNT');
      expect(sale.discountValue, 20.0);
      expect(sale.discountAmount, 20.0);
      expect(sale.items.first.discountAmount, greaterThan(0));
    });

    test(
      'insertSaleWithItems with EXCLUSIVE VAT stores total with VAT',
      () async {
        final product = await seedProduct(price: 100.0, stock: 50);
        final cartItem = CartItem(product: product, qty: 1);

        final sale = await saleDatasource.insertSaleWithItems(
          items: [cartItem],
          paymentMethod: 'cash',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
        );

        expect(sale.totalAmount, closeTo(107.0, 0.01));
        expect(sale.subtotalAmount, 100.0);
        expect(sale.vatAmount, closeTo(7.0, 0.01));
        expect(sale.vatMode, 'EXCLUSIVE');
      },
    );
  });
}
