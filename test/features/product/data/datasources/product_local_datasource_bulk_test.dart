import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl datasource;
  late InventoryLogService logService;

  setUp(() {
    db = createInMemoryDatabase();
    logService = InventoryLogService(
      db,
      settingsRepo: FakeSettingsRepository(),
    );
    datasource = ProductLocalDatasourceImpl(
      db,
      ProductOptionDatasourceImpl(db),
      logService,
    );
  });

  tearDown(() => db.close());

  ProductsCompanion product({
    required String id,
    String name = 'P',
    int stock = 10,
    bool trackStock = true,
  }) => ProductsCompanion.insert(
    id: id,
    name: name,
    price: 50,
    stock: Value(stock),
    trackStock: Value(trackStock),
  );

  test('bulkUpdateBarcodes updates multiple rows', () async {
    final a = IdGenerator.newId();
    final b = IdGenerator.newId();
    await datasource.insertProduct(product(id: a, name: 'A'));
    await datasource.insertProduct(product(id: b, name: 'B'));

    await datasource.bulkUpdateBarcodes([
      (id: a, barcode: '111'),
      (id: b, barcode: '222'),
    ]);

    expect((await datasource.getProductById(a))!.barcode, '111');
    expect((await datasource.getProductById(b))!.barcode, '222');
  });

  test('bulkUpdateBarcodesWithImages sets path', () async {
    final id = IdGenerator.newId();
    await datasource.insertProduct(product(id: id));
    await datasource.bulkUpdateBarcodesWithImages([
      (id: id, barcode: '999', barcodeImagePath: '/tmp/bc.png'),
    ]);
    final p = (await datasource.getProductById(id))!;
    expect(p.barcode, '999');
    expect(p.barcodeImagePath, '/tmp/bc.png');
  });

  test('updateProduct with stock change writes inventory log', () async {
    final id = IdGenerator.newId();
    await datasource.insertProduct(product(id: id, stock: 10));
    await datasource.updateProduct(
      ProductsCompanion(id: Value(id), stock: const Value(15)),
    );
    final logs = await (db.select(
      db.inventoryLogs,
    )..where((t) => t.productId.equals(id))).get();
    expect(logs, isNotEmpty);
    expect(logs.single.qtyChange, 5);
    expect(logs.single.type, 'ADJUSTMENT_IN');
  });

  test('insertProductWithOptionGroups persists groups', () async {
    final id = IdGenerator.newId();
    final gid = IdGenerator.newId();
    final oid = IdGenerator.newId();
    await datasource.insertProductWithOptionGroups(
      product(id: id, name: 'Combo'),
      [
        ProductOptionGroup(
          id: gid,
          productId: id,
          name: 'Size',
          selectionType: OptionSelectionType.single,
          isRequired: true,
          sortOrder: 0,
          options: [
            ProductOption(
              id: oid,
              groupId: gid,
              name: 'L',
              priceDelta: Money.fromDouble(10),
            ),
          ],
        ),
      ],
    );

    final loaded = await datasource.getProductById(id);
    expect(loaded, isNotNull);
    expect(loaded!.optionGroups.length, 1);
    expect(loaded.optionGroups.first.options.single.name, 'L');
  });

  test('countSaleItemsByProduct and countDraftItemsByProduct', () async {
    final pid = IdGenerator.newId();
    await datasource.insertProduct(product(id: pid));
    expect(await datasource.countSaleItemsByProduct(pid), 0);
    expect(await datasource.countDraftItemsByProduct(pid), 0);

    final saleId = IdGenerator.newId();
    await db
        .into(db.sales)
        .insert(
          SalesCompanion.insert(
            id: saleId,
            totalAmount: 50,
            paymentMethod: 'cash',
          ),
        );
    await db
        .into(db.saleItems)
        .insert(
          SaleItemsCompanion.insert(
            id: IdGenerator.newId(),
            saleId: saleId,
            productId: pid,
            productName: 'P',
            price: 50,
            qty: 2,
            subtotal: 100,
          ),
        );

    expect(await datasource.countSaleItemsByProduct(pid), 1);
  });

  test('getAllProducts returns inactive too', () async {
    final a = IdGenerator.newId();
    final b = IdGenerator.newId();
    await datasource.insertProduct(product(id: a, name: 'On'));
    await datasource.insertProduct(product(id: b, name: 'Off'));
    await datasource.updateProduct(
      ProductsCompanion(id: Value(b), isActive: const Value(false)),
    );
    final all = await datasource.getAllProducts();
    expect(all.length, 2);
    final active = await datasource.getActiveProducts();
    expect(active.length, 1);
    expect(active.single.name, 'On');
  });
}
