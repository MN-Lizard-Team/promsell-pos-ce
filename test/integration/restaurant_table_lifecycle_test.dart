import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/restaurant_table/data/repositories/restaurant_table_repository_impl.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';

import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

/// Restaurant-table lifecycle over the REAL Drift schema:
///
/// - Occupancy is DERIVED from active draft carts
///   (`is_archived = 0 AND deleted_at IS NULL AND table_id = ?`), so paying a
///   parked bill frees its table the instant the sale transaction commits.
/// - The partial unique index `idx_draft_carts_table_id_unique` guarantees at
///   most ONE active cart per table.
void main() {
  late AppDatabase db;
  late FakeSettingsRepository fakeSettingsRepo;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late DraftCartLocalDatasourceImpl draftDs;
  late RestaurantTableRepositoryImpl tableRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
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
    tableRepo = RestaurantTableRepositoryImpl(
      db,
      settingsRepo: fakeSettingsRepo,
    );
  });

  tearDown(() => db.close());

  Future<Product> seedProduct(String id) async {
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Item-$id',
        price: 100.0,
        stock: const Value(50),
      ),
    );
    final row = await (db.select(
      db.products,
    )..where((p) => p.id.equals(id))).getSingle();
    return Product(
      id: row.id,
      name: row.name,
      price: Money.fromDouble(row.price),
      stock: row.stock,
      isActive: row.isActive,
      trackStock: row.trackStock,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Fresh line identity per bill — line ids are the draft_cart_items PK.
  CartItem itemOf(Product product, String billTag) =>
      CartItem(product: product, qty: 1, lineId: 'line-$billTag-${product.id}');

  /// Parks a real cart holding [products] bound to [tableId] via the
  /// datasource.
  Future<String> parkCart(String tableId, List<Product> products) async {
    final cartId = await draftDs.createDraft(name: 'Bill $tableId');
    await draftDs.upsertDraft(
      cartId,
      CartSnapshot(
        items: [for (final p in products) itemOf(p, cartId)],
        tableId: tableId,
      ),
    );
    return cartId;
  }

  Future<bool> cartRowExists(String cartId) async {
    final rows = await (db.select(
      db.draftCarts,
    )..where((c) => c.id.equals(cartId))).get();
    return rows.isNotEmpty;
  }

  Future<int> activeCartCountForTable(String tableId) async {
    final rows =
        await (db.select(db.draftCarts)..where(
              (c) =>
                  c.tableId.equals(tableId) &
                  c.isArchived.equals(false) &
                  c.deletedAt.isNull(),
            ))
            .get();
    return rows.length;
  }

  Future<int> cartItemCount(String cartId) {
    final countExp = db.draftCartItems.id.count();
    return (db.selectOnly(db.draftCartItems)
          ..where(db.draftCartItems.cartId.equals(cartId))
          ..addColumns([countExp]))
        .getSingle()
        .then((row) => row.read(countExp) ?? 0);
  }

  group('atomic checkout frees the table', () {
    test(
      'paying a parked bill deletes THAT cart and un-occupies the table',
      () async {
        final product = await seedProduct('p1');
        final tableId = await tableRepo.addTable(name: 'T1');
        final cartId = await parkCart(tableId, [product]);

        // Bound → effective occupied before payment.
        expect(
          (await tableRepo.getTableById(tableId))!.status,
          TableStatus.occupied,
        );
        expect(await activeCartCountForTable(tableId), 1);

        final sale = await saleDs.insertSaleWithItems(
          items: [itemOf(product, 'sale-1')],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          orderType: 'dinein',
          originatingDraftCartId: cartId,
        );
        expect(sale.receiptNumber, isNotNull);

        // The draft cart + its items are GONE in the same commit as the sale.
        expect(await cartRowExists(cartId), isFalse);
        expect(await cartItemCount(cartId), 0);

        // No second step needed: the table already reports NOT occupied.
        final t = (await tableRepo.getTableById(tableId))!;
        expect(t.status, isNot(TableStatus.occupied));
        expect(t.status, TableStatus.available);
      },
    );

    test(
      'never-parked ephemeral cart: checkout succeeds with nothing to delete',
      () async {
        final product = await seedProduct('p2');
        final sale = await saleDs.insertSaleWithItems(
          items: [itemOf(product, 'sale-2')],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );
        expect(sale.receiptNumber, isNotNull);
        // Sanity: no draft rows exist at all.
        expect(await db.select(db.draftCarts).get(), isEmpty);
      },
    );
  });

  group('one active bill per table (idx_draft_carts_table_id_unique)', () {
    test('second active bill for the same table is rejected', () async {
      final product = await seedProduct('p3');
      final tableId = await tableRepo.addTable(name: 'T2');
      final firstCart = await parkCart(tableId, [product]);

      final secondCart = await draftDs.createDraft(name: 'Second');
      await expectLater(
        draftDs.upsertDraft(
          secondCart,
          CartSnapshot(items: [itemOf(product, secondCart)], tableId: tableId),
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            'TableAlreadyBound',
          ),
        ),
      );

      // First binding untouched; still exactly one active cart.
      expect(await cartRowExists(firstCart), isTrue);
      expect(await activeCartCountForTable(tableId), 1);
    });

    test('archiving the first bill allows binding the table again', () async {
      final product = await seedProduct('p4');
      final tableId = await tableRepo.addTable(name: 'T3');
      final firstCart = await parkCart(tableId, [product]);

      // Archive (what saved-bill cleanup does) → cart no longer "active".
      await (db.update(db.draftCarts)..where((c) => c.id.equals(firstCart)))
          .write(const DraftCartsCompanion(isArchived: Value(true)));

      final secondCart = await draftDs.createDraft(name: 'Second');
      // Must NOT throw now that the previous cart is inactive.
      await draftDs.upsertDraft(
        secondCart,
        CartSnapshot(items: [itemOf(product, secondCart)], tableId: tableId),
      );
      expect(await cartRowExists(secondCart), isTrue);
      expect(await activeCartCountForTable(tableId), 1);
    });
  });

  group('wrong-cart regression (draft switched mid-payment)', () {
    test('paying draft A while B is active deletes ONLY A', () async {
      final water = await seedProduct('water');
      final coke = await seedProduct('coke');

      final tableA = await tableRepo.addTable(name: 'A');
      final tableB = await tableRepo.addTable(name: 'B');
      final draftA = await parkCart(tableA, [water]);
      final draftB = await parkCart(tableB, [coke]);

      // Cashier started paying A, then switched the active bill to B.
      // CheckoutBloc freezes draftCartId='draft-A'; completion passes THAT id
      // into the transaction, so deletion can never follow the live pointer.
      final sale = await saleDs.insertSaleWithItems(
        items: [itemOf(water, 'sale-A')],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        originatingDraftCartId: draftA,
      );

      // A is gone…
      expect(await cartRowExists(draftA), isFalse);
      // …B is fully intact — header and item lines survive.
      expect(await cartRowExists(draftB), isTrue);
      expect(await cartItemCount(draftB), 1);

      // Only A's table was freed; B still occupied.
      expect(
        (await tableRepo.getTableById(tableA))!.status,
        TableStatus.available,
      );
      expect(
        (await tableRepo.getTableById(tableB))!.status,
        TableStatus.occupied,
      );

      // Exactly one sale recorded.
      final sales = await db.select(db.sales).get();
      expect(sales.single.id, sale.id);
    });
  });

  group('reserved manual status survives occupancy', () {
    test('mark reserved persists; occupied while bound; back to reserved after '
        'paying', () async {
      final product = await seedProduct('p5');
      final tableId = await tableRepo.addTable(name: 'VIP');

      // Manual reserve persists.
      await tableRepo.updateTableStatus(tableId, TableStatus.reserved);
      var t = (await tableRepo.getTableById(tableId))!;
      expect(t.status, TableStatus.reserved);
      expect(t.manualStatus, TableStatus.reserved);

      // Guests arrive — an open bill makes it effectively occupied.
      final cartId = await parkCart(tableId, [product]);
      t = (await tableRepo.getTableById(tableId))!;
      expect(t.status, TableStatus.occupied);
      expect(t.manualStatus, TableStatus.reserved);

      // Paying returns the EFFECTIVE status to the stored manual value.
      await saleDs.insertSaleWithItems(
        items: [itemOf(product, 'sale-5')],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        originatingDraftCartId: cartId,
      );
      t = (await tableRepo.getTableById(tableId))!;
      expect(t.status, TableStatus.reserved);
      expect(t.manualStatus, TableStatus.reserved);
    });
  });

  group('live watch reflects lifecycle without reloads', () {
    test('bind → pay flips effective status without any reload', () async {
      final product = await seedProduct('p6');
      final tableId = await tableRepo.addTable(name: 'T6');

      final statuses = <TableStatus>[];
      final sub = tableRepo.watchTables().listen((tables) {
        statuses.add(tables.firstWhere((t) => t.id == tableId).status);
      });
      addTearDown(sub.cancel);
      await drainUntil(statuses, (s) => s.isNotEmpty);
      expect(statuses.first, TableStatus.available);

      // Binding may emit intermediate frames (row created, then bound).
      final cartId = await parkCart(tableId, [product]);
      await drainUntil(statuses, (s) => s.contains(TableStatus.occupied));
      expect(statuses.last, TableStatus.occupied);

      await saleDs.insertSaleWithItems(
        items: [itemOf(product, 'sale-6')],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        originatingDraftCartId: cartId,
      );
      await drainUntil(
        statuses,
        (s) => s.isNotEmpty && s.last == TableStatus.available,
      );
      expect(statuses.last, TableStatus.available);
    });
  });
}

Future<void> drainUntil(
  List<TableStatus> statuses,
  bool Function(List<TableStatus>) predicate,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!predicate(statuses)) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for watch emission; got: $statuses');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
