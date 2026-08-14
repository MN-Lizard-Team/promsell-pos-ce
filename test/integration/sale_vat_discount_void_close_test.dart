import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
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
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
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

/// V092-D.1 — Host integration: full money path with VAT + discount + void +
/// day-close. One file, one story.
///
/// Proves: real bill → persist → payable matches SalePayableCalculator →
/// void restocks → day-close totals match.
void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late SaleRepositoryImpl saleRepo;
  late CloseDay closeDay;
  late VoidSale voidSale;
  late GetDailyCloseByDate getDailyCloseByDate;
  late _VatSettingsRepo settingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    settingsRepo = _VatSettingsRepo();
    final inventory = InventoryLogService(db, settingsRepo: settingsRepo);
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: inventory,
      settingsRepo: settingsRepo,
    );
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
    saleRepo = SaleRepositoryImpl(saleDs);
    getDailyCloseByDate = GetDailyCloseByDate(
      DailyCloseRepositoryImpl(DailyCloseLocalDatasourceImpl(db)),
    );
    closeDay = CloseDay(
      DailyCloseRepositoryImpl(DailyCloseLocalDatasourceImpl(db)),
      saleRepo,
      fakeAppLock(),
    );
    voidSale = VoidSale(
      saleRepo,
      settingsRepo,
      getDailyCloseByDate,
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

  group('V092-D.1: full VAT money path', () {
    test(
      'case 1: EXCLUSIVE 7% no discount → totalAmount matches golden 10700 satang, stock down',
      () async {
        settingsRepo.setVat(mode: 'EXCLUSIVE', rate: 7.0);
        final product = await seedProduct('p1', stock: 10);

        final sale = await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'cash',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
        );

        // Golden: 100.00 × 1 = 100.00 preTax; VAT 7% = 7.00; payable = 107.00
        // = 10700 satang.
        expect(sale.totalAmount, Money.fromDouble(107.0));
        expect(sale.vatAmount, Money.fromDouble(7.0));
        expect(sale.subtotalAmount, Money.fromDouble(100.0));
        expect(sale.status, 'COMPLETED');

        // Cross-check with SalePayableCalculator (SSOT).
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(100.0),
            vatMode: 'EXCLUSIVE',
            vatRate: 7.0,
          ),
        );
        expect(totals.payableTotal, sale.totalAmount);
        expect(totals.vatAmount, sale.vatAmount);

        // Stock down by 1, version bumped.
        final after = (await productDs.getProductById('p1'))!;
        expect(after.stock, 9);
        expect(after.version, greaterThan(product.version));
      },
    );

    test(
      'case 2: cart discount + EXCLUSIVE 7% → total matches calculator → void → stock back + VOID_REVERSAL log',
      () async {
        settingsRepo.setVat(mode: 'EXCLUSIVE', rate: 7.0);
        final product = await seedProduct('p2', stock: 20);

        // Cart discount 10.00 fixed.
        const cartDiscountAmount = 10.0;
        final sale = await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 2)],
          paymentMethod: 'cash',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
          cartDiscountType: 'fixed',
          cartDiscountValue: cartDiscountAmount,
          cartDiscountAmount: Money.fromDouble(cartDiscountAmount),
        );

        // 2 × 100 = 200 subtotal − 10 discount = 190 net; VAT 7% = 13.30;
        // payable = 203.30 = 20330 satang.
        final expected = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(200.0),
            cartDiscountAmount: Money.fromDouble(10.0),
            vatMode: 'EXCLUSIVE',
            vatRate: 7.0,
          ),
        );
        expect(sale.totalAmount, expected.payableTotal);
        expect(sale.discountAmount, Money.fromDouble(10.0));
        expect(sale.vatAmount, expected.vatAmount);

        // Stock down by 2.
        var after = (await productDs.getProductById('p2'))!;
        expect(after.stock, 18);

        // Void via use case (not datasource bypass).
        await voidSale(sale.id, reason: 'test void');

        // Stock restored.
        after = (await productDs.getProductById('p2'))!;
        expect(after.stock, 20);

        // Sale status = VOIDED.
        final voided = await saleDs.querySaleById(sale.id);
        expect(voided!.status, 'VOIDED');

        // Inventory log has VOID_REVERSAL.
        final logs = await db.select(db.inventoryLogs).get();
        final reversal = logs.where((l) => l.type == 'VOID_REVERSAL').toList();
        expect(reversal, isNotEmpty);
        expect(reversal.first.qtyChange, 2);
        expect(reversal.first.balanceAfter, 20);
      },
    );

    test(
      'case 3: dailyCloseLock on + day closed → VoidSale throws BusinessRuleError (not datasource bypass)',
      () async {
        settingsRepo
          ..setVat(mode: 'EXCLUSIVE', rate: 7.0)
          ..setDailyCloseLock(on: true, lastClosedDate: todayIso());

        final product = await seedProduct('p3', stock: 5);
        final sale = await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'cash',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
        );

        // Close the day first (so dayRowClosed = true).
        await closeDay(
          date: todayIso(),
          openingCash: 0,
          countedCash: 107.0,
          deviceId: 'test-device',
        );

        // VoidSale should throw BusinessRuleError(ruleDayClosed).
        expect(
          () => voidSale(sale.id, reason: 'after close'),
          throwsA(
            isA<BusinessRuleError>().having(
              (e) => e.rule,
              'rule',
              SalesDayLock.ruleDayClosed,
            ),
          ),
        );

        // Stock NOT restored — sale still COMPLETED.
        final after = (await productDs.getProductById('p3'))!;
        expect(after.stock, 4);
        final stillCompleted = await saleDs.querySaleById(sale.id);
        expect(stillCompleted!.status, 'COMPLETED');
      },
    );

    test(
      'day-close totals match SalePayableCalculator after EXCLUSIVE VAT sale',
      () async {
        settingsRepo.setVat(mode: 'EXCLUSIVE', rate: 7.0);
        final product = await seedProduct('p4', stock: 10);

        await saleDs.insertSaleWithItems(
          items: [CartItem(product: product, qty: 1)],
          paymentMethod: 'cash',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
        );

        final closed = await closeDay(
          date: todayIso(),
          openingCash: 0,
          countedCash: 107.0,
          deviceId: 'test-device',
        );

        expect(closed.totalRevenue, Money.fromDouble(107.0));
        expect(closed.vatAmount, Money.fromDouble(7.0));
        expect(closed.salesCount, 1);
        expect(closed.expectedCash, Money.fromDouble(107.0));
        expect(closed.overShortAmount, Money.zero);
      },
    );
  });
}

/// Settings repo with configurable VAT + daily-close lock for integration tests.
class _VatSettingsRepo implements SettingsRepository {
  _VatSettingsRepo();

  String _vatMode = 'NONE';
  double _vatRate = 0;
  bool _dailyCloseLock = false;
  String? _lastClosedDate;

  void setVat({required String mode, required double rate}) {
    _vatMode = mode;
    _vatRate = rate;
  }

  void setDailyCloseLock({required bool on, String? lastClosedDate}) {
    _dailyCloseLock = on;
    _lastClosedDate = lastClosedDate;
  }

  @override
  Future<Settings> load() async => Settings(
    deviceConfig: const DeviceConfig(
      deviceId: 'test-device',
      devicePrefix: 'T1',
    ),
    stockConfig: const StockConfig(),
    taxConfig: TaxConfig(vatMode: _vatMode, vatRate: _vatRate),
    dailyCloseConfig: DailyCloseConfig(
      dailyCloseLock: _dailyCloseLock,
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
