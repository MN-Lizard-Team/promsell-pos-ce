import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/daily_close/data/datasources/daily_close_local_datasource.dart';
import 'package:promsell_pos_ce/features/daily_close/data/repositories/daily_close_repository_impl.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/void_sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/daily_close_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

import '../helpers/fake_app_lock.dart';
import '../helpers/fake_database.dart';

/// V092-D.4 — Void after day-close, full stack.
///
/// Walks `VoidSale` on a real DB + `dailyCloseLock` + a `daily_closes` row.
/// Must live in trust (release-trust.yml).
///
/// Covers both block paths in `SalesDayLock.isVoidBlocked`:
/// (a) settings `lastClosedDate` matches sale date
/// (b) `daily_closes` row exists with `closedAt` set (dayRowClosed = true)
void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late SaleRepositoryImpl saleRepo;
  late CloseDay closeDay;
  late VoidSale voidSale;
  late _DayLockSettingsRepo settingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    settingsRepo = _DayLockSettingsRepo();
    final inventory = InventoryLogService(db, settingsRepo: settingsRepo);
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: inventory,
      settingsRepo: settingsRepo,
    );
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
    saleRepo = SaleRepositoryImpl(saleDs);
    final dailyCloseRepo = DailyCloseRepositoryImpl(
      DailyCloseLocalDatasourceImpl(db),
    );
    closeDay = CloseDay(dailyCloseRepo, saleRepo, fakeAppLock());
    voidSale = VoidSale(
      saleRepo,
      settingsRepo,
      GetDailyCloseByDate(dailyCloseRepo),
      fakeAppLock(),
    );
  });

  tearDown(() => db.close());

  Future<Product> seedProduct(String id, {required int stock}) async {
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Item-$id',
        price: 100.0,
        stock: Value(stock),
      ),
    );
    return (await productDs.getProductById(id))!;
  }

  String todayIso() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  group('V092-D.4: void after day-close (full stack)', () {
    test(
      'block path (a): settings lastClosedDate = sale date → VoidSale throws',
      () async {
        // Sale first.
        final product = await seedProduct('p1', stock: 10);
        final sale = await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );

        // Enable lock + set lastClosedDate to today (sale's date).
        settingsRepo.setLock(on: true, lastClosedDate: todayIso());

        expect(
          () => voidSale(sale.id),
          throwsA(
            isA<BusinessRuleError>().having(
              (e) => e.rule,
              'rule',
              SalesDayLock.ruleDayClosed,
            ),
          ),
        );

        // Stock not restored.
        final after = (await productDs.getProductById('p1'))!;
        expect(after.stock, 9);
      },
    );

    test(
      'block path (b): daily_closes row closed → VoidSale throws (no settings lastClosedDate)',
      () async {
        final product = await seedProduct('p2', stock: 10);
        final sale = await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );

        // Lock on but lastClosedDate NOT set — rely on daily_closes row.
        settingsRepo.setLock(on: true, lastClosedDate: null);

        // Close the day → creates daily_closes row with closedAt.
        await closeDay(
          date: todayIso(),
          openingCash: 0,
          countedCash: 100.0,
          deviceId: 'test-device',
        );

        expect(
          () => voidSale(sale.id),
          throwsA(
            isA<BusinessRuleError>().having(
              (e) => e.rule,
              'rule',
              SalesDayLock.ruleDayClosed,
            ),
          ),
        );

        final after = (await productDs.getProductById('p2'))!;
        expect(after.stock, 9);
      },
    );

    test(
      'allow path: lock off → void succeeds even with daily_closes row',
      () async {
        final product = await seedProduct('p3', stock: 10);
        final sale = await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 2)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );

        // Lock OFF — close day then void should still work.
        await closeDay(
          date: todayIso(),
          openingCash: 0,
          countedCash: 200.0,
          deviceId: 'test-device',
        );

        await voidSale(sale.id, reason: 'post-close void');

        final after = (await productDs.getProductById('p3'))!;
        expect(after.stock, 10); // restored

        final voided = await saleDs.querySaleById(sale.id);
        expect(voided!.status, 'VOIDED');
      },
    );

    test(
      'allow path: lock on but sale date != closed date → void succeeds',
      () async {
        final product = await seedProduct('p4', stock: 10);
        final sale = await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        );

        // Lock on, lastClosedDate is yesterday — sale is today.
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yIso =
            '${yesterday.year.toString().padLeft(4, '0')}-'
            '${yesterday.month.toString().padLeft(2, '0')}-'
            '${yesterday.day.toString().padLeft(2, '0')}';
        settingsRepo.setLock(on: true, lastClosedDate: yIso);

        await voidSale(sale.id, reason: 'different day');

        final after = (await productDs.getProductById('p4'))!;
        expect(after.stock, 10); // restored
      },
    );
  });
}

/// Settings repo with configurable daily-close lock.
class _DayLockSettingsRepo implements SettingsRepository {
  _DayLockSettingsRepo();

  bool _lock = false;
  String? _lastClosedDate;

  void setLock({required bool on, String? lastClosedDate}) {
    _lock = on;
    _lastClosedDate = lastClosedDate;
  }

  @override
  Future<Settings> load() async => Settings(
    deviceConfig: const DeviceConfig(
      deviceId: 'test-device',
      devicePrefix: 'T1',
    ),
    stockConfig: const StockConfig(),
    taxConfig: const TaxConfig(),
    dailyCloseConfig: DailyCloseConfig(
      dailyCloseLock: _lock,
      lastClosedDate: _lastClosedDate,
    ),
    businessConfig: const BusinessConfig(),
  );

  @override
  Future<void> save(Settings settings) async {}

  @override
  Future<void> saveBarcodeLastCounter(int counter) async {}

  @override
  Future<void> saveSkuLastCounter(int counter) async {}
}
