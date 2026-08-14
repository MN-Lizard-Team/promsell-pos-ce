import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/daily_close/data/datasources/daily_close_local_datasource.dart';
import 'package:promsell_pos_ce/features/daily_close/data/repositories/daily_close_repository_impl.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

import '../helpers/fake_app_lock.dart';
import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

/// POST-090 B1: multi-tender sale → CloseDay expected cash uses cash lines only.
void main() {
  late AppDatabase db;
  late SaleLocalDatasourceImpl saleDs;
  late ProductLocalDatasourceImpl productDs;
  late CloseDay closeDay;

  setUp(() {
    db = createInMemoryDatabase();
    final settings = FakeSettingsRepository();
    final inventory = InventoryLogService(db, settingsRepo: settings);
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: inventory,
      settingsRepo: settings,
    );
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
    closeDay = CloseDay(
      DailyCloseRepositoryImpl(DailyCloseLocalDatasourceImpl(db)),
      SaleRepositoryImpl(saleDs),
      fakeAppLock(),
    );
  });

  tearDown(() => db.close());

  test(
    'close day expectedCash = opening + cash tenders only (multi-tender + cash)',
    () async {
      await productDs.insertProduct(
        ProductsCompanion.insert(
          id: 'p1',
          name: 'Item',
          price: 100,
          stock: const Value(20),
        ),
      );
      final product = (await productDs.getProductById('p1'))!;

      // Mixed 100: cash 40 + promptpay 60
      await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'mixed',
        vatMode: 'NONE',
        vatRate: 0,
        payments: [
          SalePayment(method: 'cash', amount: Money.fromDouble(40)),
          SalePayment(method: 'promptpay', amount: Money.fromDouble(60)),
        ],
      );

      // Pure cash 100 (full bill)
      await saleDs.insertSaleWithItems(
        items: [CartItem(product: product, qty: 1)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        payments: [SalePayment(method: 'cash', amount: Money.fromDouble(100))],
      );

      final today = DateTime.now();
      final date =
          '${today.year.toString().padLeft(4, '0')}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      const opening = 100.0;
      // expected cash drawer: 100 + 40 (mixed cash line) + 100 = 240
      final closed = await closeDay(
        date: date,
        openingCash: opening,
        countedCash: 240,
        deviceId: 'test-device',
      );

      expect(closed.expectedCash, Money.fromDouble(240));
      expect(closed.overShortAmount, Money.zero);
      expect(closed.totalRevenue, Money.fromDouble(200));
      expect(closed.salesCount, 2);
      expect(closed.paymentBreakdown['cash'], 140);
      expect(closed.paymentBreakdown['promptpay'], 60);
      expect(closed.paymentBreakdown['mixed'], isNull);

      final reloaded = await DailyCloseRepositoryImpl(
        DailyCloseLocalDatasourceImpl(db),
      ).getByDate(date);
      expect(reloaded!.expectedCash, Money.fromDouble(240));
      expect(reloaded.paymentBreakdown['cash'], 140);
    },
  );
}
