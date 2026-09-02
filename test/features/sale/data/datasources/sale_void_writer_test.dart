import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late SaleLocalDatasourceImpl saleDs;
  late ProductLocalDatasourceImpl productDs;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(
        db,
        settingsRepo: fakeSettingsRepo,
      ),
      settingsRepo: fakeSettingsRepo,
    );
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
  });

  tearDown(() => db.close());

  Future<CartItem> seedProductItem({
    String id = 'prod-1',
    int stock = 50,
    bool trackStock = true,
    int qty = 1,
    String lineId = 'L1',
  }) async {
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Product-$id',
        price: 100.0,
        stock: Value(stock),
        trackStock: Value(trackStock),
      ),
    );
    final data = await (db.select(
      db.products,
    )..where((t) => t.id.equals(id))).getSingle();
    return CartItem(
      product: Product(
        id: data.id,
        name: data.name,
        price: Money.fromDouble(data.price),
        stock: data.stock,
        isActive: data.isActive,
        trackStock: data.trackStock,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      ),
      qty: qty,
      lineId: lineId,
    );
  }

  Future<List<InventoryLogData>> reversalLogs(String saleId) =>
      (db.select(db.inventoryLogs)..where(
            (t) => t.refSaleId.equals(saleId) & t.type.equals('VOID_REVERSAL'),
          ))
          .get();

  group('void edge paths', () {
    test(
      'product deleted since sale logs reversal without stock restore',
      () async {
        final item = await seedProductItem(id: 'prod-gone');
        final sale = await saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );
        await (db.delete(
          db.products,
        )..where((t) => t.id.equals('prod-gone'))).go();

        await saleDs.voidSale(sale.id, reason: 'test');

        final logs = await reversalLogs(sale.id);
        expect(logs, hasLength(1));
        expect(logs.single.type, 'VOID_REVERSAL');
        expect(logs.single.productId, 'prod-gone');
        expect(logs.single.qtyChange, 1);
        expect(logs.single.balanceAfter, -1);
        expect(logs.single.reason, 'Product deleted since sale');
      },
    );

    test('trackStock=false logs reversal with unchanged balance', () async {
      final item = await seedProductItem(id: 'prod-notrack', trackStock: false);
      final sale = await saleDs.insertSaleWithItems(
        items: [item],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      );

      await saleDs.voidSale(sale.id, reason: 'test');

      final logs = await reversalLogs(sale.id);
      expect(logs, hasLength(1));
      expect(logs.single.type, 'VOID_REVERSAL');
      expect(logs.single.qtyChange, 1);
      expect(logs.single.balanceAfter, 50);

      final product = await (db.select(
        db.products,
      )..where((t) => t.id.equals('prod-notrack'))).getSingle();
      expect(product.stock, 50);
    });

    test(
      'multiple lines of one product merge into a single reversal',
      () async {
        final product = await seedProductItem(id: 'prod-merge');
        final line1 = CartItem(product: product.product, qty: 2, lineId: 'LA');
        final line2 = CartItem(product: product.product, qty: 3, lineId: 'LB');
        final sale = await saleDs.insertSaleWithItems(
          items: [line1, line2],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );

        var row = await (db.select(
          db.products,
        )..where((t) => t.id.equals('prod-merge'))).getSingle();
        expect(row.stock, 45);

        await saleDs.voidSale(sale.id, reason: 'test');

        row = await (db.select(
          db.products,
        )..where((t) => t.id.equals('prod-merge'))).getSingle();
        expect(row.stock, 50);

        final logs = await reversalLogs(sale.id);
        expect(logs, hasLength(1));
        expect(logs.single.qtyChange, 5);
        expect(logs.single.balanceAfter, 50);
      },
    );
  });
}
