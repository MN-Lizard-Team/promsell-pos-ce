import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late SaleLocalDatasourceImpl saleDs;
  late DraftCartLocalDatasourceImpl draftDs;
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
    draftDs = DraftCartLocalDatasourceImpl(db, settingsRepo: fakeSettingsRepo);
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
  });

  tearDown(() => db.close());

  Future<CartItem> seedProductItem({
    String lineId = 'L1',
    double price = 100,
    int stock = 50,
    int qty = 1,
  }) async {
    final id = 'prod-$lineId';
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Product-$lineId',
        price: price,
        stock: Value(stock),
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

  Future<String> seedDraftCart(List<CartItem> items) async {
    final cartId = await draftDs.createDraft(name: 'Parked');
    await draftDs.upsertDraft(cartId, CartSnapshot(items: items));
    return cartId;
  }

  group('partial checkout validation', () {
    test('empty selection is rejected', () async {
      final item = await seedProductItem();

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          selectedItemIds: const [],
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'PartialCheckoutEmptySelection',
          ),
        ),
      );
    });

    test('cart discount is unsupported on partial checkout', () async {
      final item = await seedProductItem();
      final cartId = await seedDraftCart([item]);

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          cartDiscountAmount: Money.fromDouble(10),
          originatingDraftCartId: cartId,
          selectedItemIds: const ['L1'],
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'PartialCheckoutDiscountUnsupported',
          ),
        ),
      );
    });

    test('service charge is unsupported on partial checkout', () async {
      final item = await seedProductItem();
      final cartId = await seedDraftCart([item]);

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          serviceChargeRate: 10,
          originatingDraftCartId: cartId,
          selectedItemIds: const ['L1'],
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'PartialCheckoutDiscountUnsupported',
          ),
        ),
      );
    });

    test('partial checkout without a draft cart is rejected', () async {
      final item = await seedProductItem();

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          selectedItemIds: const ['L1'],
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'PartialCheckoutDraftRequired',
          ),
        ),
      );
    });

    test('unknown selected line is rejected', () async {
      final item = await seedProductItem(lineId: 'L1');
      final ghost = await seedProductItem(lineId: 'GHOST');
      final cartId = await seedDraftCart([item]);

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item, ghost],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          originatingDraftCartId: cartId,
          selectedItemIds: const ['L1', 'GHOST'],
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'PartialCheckoutLineUnavailable',
          ),
        ),
      );
    });

    test('already-fired line is rejected', () async {
      final item = await seedProductItem();
      final cartId = await seedDraftCart([item]);
      await draftDs.fireUnfiredLines(cartId);

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          originatingDraftCartId: cartId,
          selectedItemIds: const ['L1'],
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'PartialCheckoutLineUnavailable',
          ),
        ),
      );
    });
  });

  group('catalog guards', () {
    test('deleted product fails closed with NotFoundError', () async {
      final item = await seedProductItem();
      await (db.delete(
        db.products,
      )..where((t) => t.id.equals(item.product.id))).go();

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        ),
        throwsA(isA<NotFoundError>()),
      );
    });

    test('inactive product is rejected', () async {
      final item = await seedProductItem();
      await (db.update(db.products)..where((t) => t.id.equals(item.product.id)))
          .write(const ProductsCompanion(isActive: Value(false)));

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'ProductInactive',
          ),
        ),
      );
    });

    test('insufficient stock is rejected when oversell is off', () async {
      final item = await seedProductItem(stock: 1, qty: 3);

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [item],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'InsufficientStock',
          ),
        ),
      );
    });
  });

  group('partial checkout draft cleanup', () {
    test('keeps the cart and bumps version when lines remain', () async {
      final item1 = await seedProductItem(lineId: 'L1');
      final item2 = await seedProductItem(lineId: 'L2');
      final cartId = await seedDraftCart([item1, item2]);
      final before = await (db.select(
        db.draftCarts,
      )..where((t) => t.id.equals(cartId))).getSingle();

      await saleDs.insertSaleWithItems(
        items: [item1, item2],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        originatingDraftCartId: cartId,
        selectedItemIds: const ['L1'],
      );

      final after = await (db.select(
        db.draftCarts,
      )..where((t) => t.id.equals(cartId))).getSingle();
      expect(after.version, before.version + 1);

      final remaining = await (db.select(
        db.draftCartItems,
      )..where((t) => t.cartId.equals(cartId))).get();
      expect(remaining, hasLength(1));
      expect(remaining.single.id, 'L2');
    });

    test('deletes the cart when no lines remain', () async {
      final item1 = await seedProductItem(lineId: 'L1');
      final item2 = await seedProductItem(lineId: 'L2');
      final cartId = await seedDraftCart([item1, item2]);

      await saleDs.insertSaleWithItems(
        items: [item1, item2],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        originatingDraftCartId: cartId,
        selectedItemIds: const ['L1', 'L2'],
      );

      final carts = await (db.select(
        db.draftCarts,
      )..where((t) => t.id.equals(cartId))).get();
      expect(carts, isEmpty);
    });
  });
}
