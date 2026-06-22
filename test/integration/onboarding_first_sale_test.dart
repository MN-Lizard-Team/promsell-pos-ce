import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';

import '../helpers/fake_database.dart';
import '../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleLocalDatasourceImpl saleDs;
  late SettingsLocalDatasourceImpl settingsDs;
  late SettingsRepositoryImpl settingsRepo;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    productDs = ProductLocalDatasourceImpl(db);
    settingsDs = SettingsLocalDatasourceImpl(db);
    settingsRepo = SettingsRepositoryImpl(settingsDs);
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(
        db,
        settingsRepo: fakeSettingsRepo,
      ),
      settingsRepo: fakeSettingsRepo,
    );
  });

  tearDown(() => db.close());

  test('onboarding → first sale → settings persist', () async {
    // 1. Simulate onboarding: seed settings with deviceId and shop info
    final onboardingSettings = const Settings(
      deviceConfig: DeviceConfig(deviceId: 'dev-001', devicePrefix: 'A1'),
      shopInfo: ShopInfo(
        name: 'Test Shop',
        address: '123 Main St',
        phone: '0812345678',
      ),
      paymentConfig: PaymentConfig(currency: '฿'),
    );
    await settingsRepo.save(onboardingSettings);

    // 2. Verify settings persisted
    final loaded = await settingsRepo.load();
    expect(loaded.deviceConfig.deviceId, 'dev-001');
    expect(loaded.shopInfo.name, 'Test Shop');

    // 3. Add a product
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: 'p1',
        name: 'Widget',
        price: 150.0,
        stock: const Value(100),
      ),
    );
    final product = (await productDs.getProductById('p1'))!;

    // 4. Create first sale
    final sale = await saleDs.insertSaleWithItems(
      items: [CartItem(product: product, qty: 2)],
      paymentMethod: 'cash',
      vatMode: 'NONE',
      vatRate: 0,
      amountReceived: 500,
      changeAmount: 200,
    );

    expect(sale.totalAmount, 300.0);
    expect(sale.receiptNumber, isNotEmpty);

    // 5. Verify stock updated
    final updatedProduct = await productDs.getProductById('p1');
    expect(updatedProduct!.stock, 98);

    // 6. Update settings and verify
    final updatedSettings = loaded.copyWithEntities(
      shopInfo: const ShopInfo(name: 'Updated Shop'),
    );
    await settingsRepo.save(updatedSettings);
    final reloaded = await settingsRepo.load();
    expect(reloaded.shopInfo.name, 'Updated Shop');
  });
}
