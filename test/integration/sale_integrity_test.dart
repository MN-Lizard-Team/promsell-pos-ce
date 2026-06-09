import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late InventoryLogService inventoryLogService;
  late AdjustStock adjustStock;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    productDs = ProductLocalDatasourceImpl(db);
    inventoryLogService = InventoryLogService(
      db,
      settingsRepo: fakeSettingsRepo,
    );
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: inventoryLogService,
      settingsRepo: fakeSettingsRepo,
    );
    adjustStock = AdjustStock(db, inventoryLogService);
  });

  tearDown(() => db.close());

  Future<void> seedProduct(String id, {required int stock}) async {
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Product-$id',
        price: 100.0,
        stock: Value(stock),
      ),
    );
  }

  Future<List<InventoryLogData>> allLogs() => db.select(db.inventoryLogs).get();

  group('Sale creates receipt number + inventory log', () {
    test('receipt number is set on sale', () async {
      await seedProduct('p1', stock: 10);
      final product = (await productDs.getProductById('p1'))!;
      final sale = await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );
      expect(sale.receiptNumber, isNotNull);
      expect(sale.receiptNumber, matches(RegExp(r'^\d{6}-[A-Z0-9]{2}-0001$')));
      expect(sale.status, 'COMPLETED');
    });

    test('inventory log created per item with type SALE', () async {
      await seedProduct('p1', stock: 10);
      final product = (await productDs.getProductById('p1'))!;
      await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 3)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      final logs = await allLogs();
      expect(logs, hasLength(1));
      expect(logs.first.type, 'SALE');
      expect(logs.first.qtyChange, -3);
      expect(logs.first.balanceAfter, 7);
      expect(logs.first.productId, 'p1');
    });
  });

  group('Void sale', () {
    test('restores stock + creates VOID_REVERSAL log', () async {
      await seedProduct('p1', stock: 20);
      final product = (await productDs.getProductById('p1'))!;
      final sale = await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 5)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      // Stock after sale: 15
      expect((await productDs.getProductById('p1'))!.stock, 15);

      await saleDs.voidSale(sale.id, reason: 'Customer refund');

      // Stock restored: 20
      expect((await productDs.getProductById('p1'))!.stock, 20);

      // Sale status is VOIDED
      final voided = await saleDs.querySaleById(sale.id);
      expect(voided!.status, 'VOIDED');
      expect(voided.voidReason, 'Customer refund');
      expect(voided.voidedAt, isNotNull);

      // Inventory logs: SALE + VOID_REVERSAL
      final logs = await allLogs();
      expect(logs, hasLength(2));
      final reversalLog = logs.firstWhere((l) => l.type == 'VOID_REVERSAL');
      expect(reversalLog.qtyChange, 5);
      expect(reversalLog.balanceAfter, 20);
    });

    test('void already voided sale throws', () async {
      await seedProduct('p1', stock: 10);
      final product = (await productDs.getProductById('p1'))!;
      final sale = await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );
      await saleDs.voidSale(sale.id);

      expect(
        () => saleDs.voidSale(sale.id),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('already voided'),
          ),
        ),
      );
    });

    test('void non-existent sale throws', () async {
      expect(
        () => saleDs.voidSale('non-existent'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Sale not found'),
          ),
        ),
      );
    });
  });

  group('AdjustStock', () {
    test('adds stock and creates ADJUSTMENT_IN log', () async {
      await seedProduct('p1', stock: 10);
      await adjustStock(productId: 'p1', qtyChange: 5, reason: 'Delivery');

      expect((await productDs.getProductById('p1'))!.stock, 15);

      final logs = await allLogs();
      expect(logs, hasLength(1));
      expect(logs.first.type, 'ADJUSTMENT_IN');
      expect(logs.first.qtyChange, 5);
      expect(logs.first.balanceAfter, 15);
      expect(logs.first.reason, 'Delivery');
    });

    test('removes stock and creates ADJUSTMENT_OUT log', () async {
      await seedProduct('p1', stock: 10);
      await adjustStock(productId: 'p1', qtyChange: -3, reason: 'Damaged');

      expect((await productDs.getProductById('p1'))!.stock, 7);

      final logs = await allLogs();
      expect(logs.first.type, 'ADJUSTMENT_OUT');
      expect(logs.first.qtyChange, -3);
    });

    test('throws when result stock would be negative', () async {
      await seedProduct('p1', stock: 2);
      expect(
        () => adjustStock(productId: 'p1', qtyChange: -5, reason: 'Oops'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('negative'),
          ),
        ),
      );
      // Stock unchanged
      expect((await productDs.getProductById('p1'))!.stock, 2);
    });

    test('throws for non-existent product', () async {
      expect(
        () => adjustStock(productId: 'ghost', qtyChange: 1, reason: 'nope'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('not found'),
          ),
        ),
      );
    });
  });

  group('Full flow: sale → void → adjust', () {
    test('combined integrity audit trail', () async {
      await seedProduct('p1', stock: 50);
      final product = (await productDs.getProductById('p1'))!;

      // 1. Sale: -10
      final sale = await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 10)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );
      expect((await productDs.getProductById('p1'))!.stock, 40);

      // 2. Void: +10
      await saleDs.voidSale(sale.id, reason: 'Wrong order');
      expect((await productDs.getProductById('p1'))!.stock, 50);

      // 3. Adjust: +5
      await adjustStock(productId: 'p1', qtyChange: 5, reason: 'Restock');
      expect((await productDs.getProductById('p1'))!.stock, 55);

      // 4. Adjust: -2
      await adjustStock(productId: 'p1', qtyChange: -2, reason: 'Damaged');
      expect((await productDs.getProductById('p1'))!.stock, 53);

      // Verify full audit trail
      final logs = await allLogs();
      expect(logs, hasLength(4));
      final types = logs.map((l) => l.type).toList();
      expect(
        types,
        containsAll([
          'SALE',
          'VOID_REVERSAL',
          'ADJUSTMENT_IN',
          'ADJUSTMENT_OUT',
        ]),
      );
    });
  });
}
