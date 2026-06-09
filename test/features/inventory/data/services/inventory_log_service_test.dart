import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late InventoryLogService service;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    service = InventoryLogService(db, settingsRepo: fakeSettingsRepo);
  });

  tearDown(() => db.close());

  Future<List<InventoryLogData>> allLogs() => db.select(db.inventoryLogs).get();

  group('logSale', () {
    test('creates a row with negative qtyChange and type SALE', () async {
      await service.logSale(
        productId: 'prod-1',
        qty: 3,
        saleId: 'sale-1',
        balanceAfter: 7,
      );

      final logs = await allLogs();
      expect(logs, hasLength(1));
      final log = logs.first;
      expect(log.type, 'SALE');
      expect(log.qtyChange, -3);
      expect(log.balanceAfter, 7);
      expect(log.productId, 'prod-1');
      expect(log.refSaleId, 'sale-1');
      expect(log.reason, isNull);
    });
  });

  group('logVoidReversal', () {
    test(
      'creates a row with positive qtyChange and type VOID_REVERSAL',
      () async {
        await service.logVoidReversal(
          productId: 'prod-1',
          qty: 5,
          saleId: 'sale-1',
          balanceAfter: 15,
        );

        final logs = await allLogs();
        expect(logs, hasLength(1));
        final log = logs.first;
        expect(log.type, 'VOID_REVERSAL');
        expect(log.qtyChange, 5);
        expect(log.balanceAfter, 15);
        expect(log.refSaleId, 'sale-1');
      },
    );
  });

  group('logAdjustment', () {
    test('positive qtyChange creates ADJUSTMENT_IN', () async {
      await service.logAdjustment(
        productId: 'prod-2',
        qtyChange: 10,
        reason: 'Restock delivery',
        balanceAfter: 50,
      );

      final logs = await allLogs();
      expect(logs, hasLength(1));
      expect(logs.first.type, 'ADJUSTMENT_IN');
      expect(logs.first.qtyChange, 10);
      expect(logs.first.reason, 'Restock delivery');
    });

    test('negative qtyChange creates ADJUSTMENT_OUT', () async {
      await service.logAdjustment(
        productId: 'prod-2',
        qtyChange: -3,
        reason: 'Damaged',
        balanceAfter: 47,
      );

      final logs = await allLogs();
      expect(logs, hasLength(1));
      expect(logs.first.type, 'ADJUSTMENT_OUT');
      expect(logs.first.qtyChange, -3);
    });

    test('zero qtyChange creates ADJUSTMENT_IN', () async {
      await service.logAdjustment(
        productId: 'prod-2',
        qtyChange: 0,
        reason: 'Correction',
        balanceAfter: 50,
      );

      final logs = await allLogs();
      expect(logs.first.type, 'ADJUSTMENT_IN');
      expect(logs.first.qtyChange, 0);
    });
  });

  test('each log gets a unique ID', () async {
    await service.logSale(
      productId: 'p1',
      qty: 1,
      saleId: 's1',
      balanceAfter: 9,
    );
    await service.logSale(
      productId: 'p1',
      qty: 2,
      saleId: 's2',
      balanceAfter: 7,
    );

    final logs = await allLogs();
    expect(logs[0].id, isNot(logs[1].id));
  });
}
