import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/exceptions/optimistic_lock_exception.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/inventory/data/datasources/inventory_log_local_datasource.dart';
import 'package:promsell_pos_ce/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

/// V092-C.1 — Stock CAS + version on every stock path.
///
/// Tests that operational paths (sale / void / adjust) bump `version` and
/// that a stale product form cannot overwrite stock after a sale.
void main() {
  late AppDatabase db;
  late SaleLocalDatasourceImpl saleDatasource;
  late ProductLocalDatasourceImpl productDatasource;
  late InventoryRepositoryImpl inventoryRepo;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    saleDatasource = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(
        db,
        settingsRepo: fakeSettingsRepo,
      ),
      settingsRepo: fakeSettingsRepo,
    );
    productDatasource = ProductLocalDatasourceImpl(
      db,
      ProductOptionDatasourceImpl(db),
    );
    inventoryRepo = InventoryRepositoryImpl(
      db,
      InventoryLogLocalDatasource(db),
    );
  });

  tearDown(() => db.close());

  Future<Product> seedProduct({
    String name = 'Test Product',
    double price = 100.0,
    int stock = 10,
  }) async {
    final id = IdGenerator.newId();
    await productDatasource.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: name,
        price: price,
        stock: Value(stock),
      ),
    );
    return (await productDatasource.getProductById(id))!;
  }

  group('V092-C.1: sale bumps version', () {
    test(
      'insertSaleWithItems increments product version on stock decrement',
      () async {
        final product = await seedProduct(stock: 10);
        final versionBefore = product.version;

        await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 3)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(500),
          changeAmount: Money.fromDouble(200),
        );

        final after = await productDatasource.getProductById(product.id);
        expect(after!.stock, 7);
        expect(after.version, versionBefore + 1);
      },
    );
  });

  group('V092-C.1: void bumps version', () {
    test('voidSale increments product version on stock restore', () async {
      final product = await seedProduct(stock: 10);
      final versionBefore = product.version;

      final sale = await saleDatasource.insertSaleWithItems(
        items: [CartItem(product: product, qty: 3)],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        amountReceived: Money.fromDouble(500),
        changeAmount: Money.fromDouble(200),
      );

      // Version bumped by sale.
      var after = await productDatasource.getProductById(product.id);
      expect(after!.version, versionBefore + 1);

      await saleDatasource.voidSale(sale.id);

      // Version bumped again by void.
      after = await productDatasource.getProductById(product.id);
      expect(after!.stock, 10);
      expect(after.version, versionBefore + 2);
    });
  });

  group('V092-C.1: adjustStock bumps version', () {
    test('adjustStock increments product version on positive adjust', () async {
      final product = await seedProduct(stock: 10);
      final versionBefore = product.version;

      await inventoryRepo.adjustStock(
        productId: product.id,
        qtyChange: 5,
        reason: 'restock',
      );

      final after = await productDatasource.getProductById(product.id);
      expect(after!.stock, 15);
      expect(after.version, versionBefore + 1);
    });

    test('adjustStock increments product version on negative adjust', () async {
      final product = await seedProduct(stock: 10);
      final versionBefore = product.version;

      await inventoryRepo.adjustStock(
        productId: product.id,
        qtyChange: -3,
        reason: 'shrinkage',
      );

      final after = await productDatasource.getProductById(product.id);
      expect(after!.stock, 7);
      expect(after.version, versionBefore + 1);
    });

    test('adjustStock below zero throws', () async {
      final product = await seedProduct(stock: 2);

      expect(
        () => inventoryRepo.adjustStock(
          productId: product.id,
          qtyChange: -5,
          reason: 'too much',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('V092-C.1: stale form cannot overwrite stock', () {
    test(
      'form saves stock=10 after sale reduced to 7 — stock stays 7, not 10',
      () async {
        // Simulate: open form (stock=10, version=0) → sell 3 → save form
        // with the stale stock=10. The form's updateProduct must NOT
        // overwrite stock back to 10.
        final product = await seedProduct(stock: 10);
        final staleSnapshot = product; // stock=10, version=0

        // Sell 3 — stock drops to 7, version bumps to 1.
        await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 3)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(500),
          changeAmount: Money.fromDouble(200),
        );

        // Now the form tries to save with the stale stock=10.
        // The version check should reject this because version changed.
        // The form sends version from the stale snapshot (0), but DB is 1.
        expect(
          () => productDatasource.updateProduct(
            ProductsCompanion(
              id: Value(product.id),
              version: Value(staleSnapshot.version),
              stock: const Value(10),
              name: Value(staleSnapshot.name),
              price: Value(staleSnapshot.price.value),
            ),
          ),
          throwsA(isA<OptimisticLockException>()),
        );

        // Stock remains 7 (the sale's result), not 10 (stale form value).
        final after = await productDatasource.getProductById(product.id);
        expect(after!.stock, 7);
      },
    );

    test(
      'form save without version check does not overwrite stock after sale',
      () async {
        // If the form does NOT send a version (backwards-compatible path),
        // updateProduct still increments version. But the key rule is:
        // submit_product.dart on edit uses base.stock (latest), not
        // input.stock. So even without a version check, the form won't
        // write a stale stock value.
        //
        // This test verifies the datasource behavior: when stock is sent
        // as the current DB value (no change), no spurious log or overwrite.
        final product = await seedProduct(stock: 10);

        // Sell 3 — stock=7, version=1.
        await saleDatasource.insertSaleWithItems(
          items: [CartItem(product: product, qty: 3)],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(500),
          changeAmount: Money.fromDouble(200),
        );

        // Simulate what submit_product.dart now does on edit: use the
        // LATEST product's stock (7), not the stale form stock (10).
        final latest = await productDatasource.getProductById(product.id);
        await productDatasource.updateProduct(
          ProductsCompanion(
            id: Value(product.id),
            stock: Value(latest!.stock), // 7 — correct, no overwrite
            name: const Value('Updated Name'),
            price: const Value(200.0),
          ),
        );

        final after = await productDatasource.getProductById(product.id);
        expect(after!.stock, 7); // still 7, not 10
        expect(after.name, 'Updated Name');
      },
    );
  });
}
