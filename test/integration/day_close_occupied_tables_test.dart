import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/daily_close/data/datasources/daily_close_local_datasource.dart';
import 'package:promsell_pos_ce/features/daily_close/data/repositories/daily_close_repository_impl.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/restaurant_table/data/repositories/restaurant_table_repository_impl.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/draft_cart_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';

import '../helpers/fake_app_lock.dart';
import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

/// Gap C — day-close while a table is occupied (behavior documentation).
///
/// Pins the CURRENT v0.9.x contract so a future change is a conscious one:
/// 1. `CloseDay` succeeds even though a parked bill still occupies a table —
///    closing only aggregates PAID sales, open bills are invisible to it.
/// 2. The parked bill survives the close fully intact and still bound; the
///    table stays effectively occupied.
/// 3. Paying that bill AFTER close is gated ONLY by `dailyCloseLock`:
///    - lock off (fresh DB default): payment succeeds and frees the table;
///    - lock on: `SaleDayGuard` rejects with `DayClosed` inside the sale
///      transaction and nothing is half-deleted.
void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late DraftCartLocalDatasourceImpl draftDs;
  late RestaurantTableRepositoryImpl tableRepo;
  late CloseDay closeDay;

  setUp(() {
    db = createInMemoryDatabase();
    final fakeSettingsRepo = FakeSettingsRepository();
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
    closeDay = CloseDay(
      DailyCloseRepositoryImpl(DailyCloseLocalDatasourceImpl(db)),
      SaleRepositoryImpl(saleDs),
      fakeAppLock(),
    );
  });

  tearDown(() => db.close());

  String todayIso() => SalesDayLock.todayIso();

  Future<Product> seedProduct(String id) async {
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Item-$id',
        price: 100.0,
        stock: const Value(10),
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

  /// Parks a real active cart bound to [tableId] holding [product].
  Future<String> parkCart(String tableId, Product product) async {
    final cartId = await draftDs.createDraft(name: 'Bill $tableId');
    await draftDs.upsertDraft(
      cartId,
      CartSnapshot(
        items: [CartItem(product: product, qty: 2, lineId: 'line-$cartId-1')],
        tableId: tableId,
      ),
    );
    return cartId;
  }

  Future<void> enableDbDayLock(String date) async {
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: 'dailyCloseLock', value: 'true'),
        );
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(key: 'lastClosedDate', value: date),
        );
  }

  Future<DailyCloseData> closedDayRow(String date) => (db.select(
    db.dailyCloses,
  )..where((c) => c.closeDate.equals(date))).getSingle();

  test(
    'close day succeeds; parked bill stays intact, bound, table occupied',
    () async {
      final product = await seedProduct('p-open');
      final tableId = await tableRepo.addTable(name: 'T-Close');
      final cartId = await parkCart(tableId, product);

      // Day D closes fine despite the occupied table.
      await closeDay(
        date: todayIso(),
        openingCash: 0,
        countedCash: 0,
        deviceId: 'test-device',
      );

      final dayRow = await closedDayRow(todayIso());
      expect(dayRow.closedAt, isNotNull);
      // Open bills are invisible to the close: zero revenue, zero sales.
      expect(dayRow.totalRevenue, 0.0);
      expect(dayRow.salesCount, 0);

      // The bill survived untouched and keeps binding the table.
      final cart = await draftDs.loadDraft(cartId);
      expect(cart, isNotNull);
      expect(cart!.tableId, tableId);
      expect(cart.items.single.product.id, 'p-open');
      expect(cart.items.single.qty, 2);
      expect(await db.select(db.draftCarts).get(), hasLength(1));

      expect(
        (await tableRepo.getTableById(tableId))!.status,
        TableStatus.occupied,
      );
    },
  );

  test(
    'paying after close WITH dailyCloseLock → blocked, bill untouched',
    () async {
      final product = await seedProduct('p-locked');
      final tableId = await tableRepo.addTable(name: 'T-Locked');
      final cartId = await parkCart(tableId, product);

      await closeDay(
        date: todayIso(),
        openingCash: 0,
        countedCash: 0,
        deviceId: 'test-device',
      );
      await enableDbDayLock(todayIso());

      await expectLater(
        saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 2)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          orderType: 'dinein',
          tableId: tableId,
          originatingDraftCartId: cartId,
        ),
        throwsA(
          isA<BusinessRuleError>().having(
            (e) => e.rule,
            'rule',
            SalesDayLock.ruleDayClosed,
          ),
        ),
      );

      // Rejection happens before ANY deletion: bill intact + bound + occupied.
      final cart = await draftDs.loadDraft(cartId);
      expect(cart, isNotNull);
      expect(cart!.tableId, tableId);
      expect(cart.items, hasLength(1));
      expect(
        (await tableRepo.getTableById(tableId))!.status,
        TableStatus.occupied,
      );
    },
  );

  test(
    'paying after close WITHOUT lock → succeeds and frees the table',
    () async {
      final product = await seedProduct('p-unlocked');
      final tableId = await tableRepo.addTable(name: 'T-Free');
      final cartId = await parkCart(tableId, product);

      await closeDay(
        date: todayIso(),
        openingCash: 0,
        countedCash: 200.0,
        deviceId: 'test-device',
      );

      // Fresh DB has no dailyCloseLock key → paying the leftover bill works.
      final sale = await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 2)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        orderType: 'dinein',
        tableId: tableId,
        originatingDraftCartId: cartId,
      );
      expect(sale.receiptNumber, isNotNull);

      // Atomic checkout deleted the originating bill → table freed.
      expect(await draftDs.loadDraft(cartId), isNull);
      expect(
        (await tableRepo.getTableById(tableId))!.status,
        TableStatus.available,
      );
    },
  );
}
