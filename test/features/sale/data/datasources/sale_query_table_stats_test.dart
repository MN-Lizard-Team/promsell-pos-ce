import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/table_sales_stat.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

void main() {
  late AppDatabase db;
  late SaleQueryLocalDatasource queryDs;
  late SaleLocalDatasourceImpl saleDs;
  late ProductLocalDatasourceImpl productDs;
  late FakeSettingsRepository fakeSettingsRepo;

  setUp(() {
    db = createInMemoryDatabase();
    fakeSettingsRepo = FakeSettingsRepository();
    queryDs = SaleQueryLocalDatasource(db);
    saleDs = SaleLocalDatasourceImpl(
      db,
      receiptNumberService: ReceiptNumberService(db),
      inventoryLogService: InventoryLogService(
        db,
        settingsRepo: fakeSettingsRepo,
      ),
      settingsRepo: fakeSettingsRepo,
    );
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
  });

  tearDown(() => db.close());

  var productSeq = 0;

  Future<CartItem> seedProductItem({double price = 100}) async {
    final id = 'prod-${productSeq++}';
    await productDs.insertProduct(
      ProductsCompanion.insert(
        id: id,
        name: 'Pad Thai',
        price: price,
        stock: const Value(50),
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
      qty: 1,
      lineId: 'L-$id',
    );
  }

  Future<String> seedSale({
    String? tableId,
    String paymentMethod = 'cash',
    double price = 100,
  }) async {
    final item = await seedProductItem(price: price);
    final sale = await saleDs.insertSaleWithItems(
      items: [item],
      paymentMethod: paymentMethod,
      vatMode: 'NONE',
      vatRate: 0,
      tableId: tableId,
    );
    return sale.id;
  }

  group('queryTableSalesStats', () {
    test('groups by table and ranks by revenue', () async {
      await seedSale(tableId: 'table-1', price: 100);
      await seedSale(tableId: 'table-1', price: 200);
      await seedSale(tableId: 'table-2', price: 50);
      await seedSale(price: 10);

      final stats = await queryDs.queryTableSalesStats();

      expect(stats, hasLength(3));
      expect(stats.first.tableId, 'table-1');
      expect(stats.first.orderCount, 2);
      expect(stats.first.revenueSatang, 30000);
      expect(stats[1].tableId, 'table-2');
      expect(stats[1].revenueSatang, 5000);
      expect(stats[2].tableId, TableSalesStat.noTableBucket);
      expect(stats[2].revenueSatang, 1000);
    });

    test('respects the limit', () async {
      await seedSale(tableId: 'table-1');
      await seedSale(tableId: 'table-2');
      await seedSale(tableId: 'table-3');

      final stats = await queryDs.queryTableSalesStats(limit: 2);

      expect(stats, hasLength(2));
    });
  });

  group('watch streams', () {
    test(
      'watchTableSalesStats emits initial then recomputes on writes',
      () async {
        await seedSale(tableId: 'table-1', price: 100);

        final done = expectLater(
          queryDs.watchTableSalesStats(),
          emitsInOrder([
            predicate<List<TableSalesStat>>(
              (s) =>
                  s.single.tableId == 'table-1' &&
                  s.single.revenueSatang == 10000,
            ),
            predicate<List<TableSalesStat>>(
              (s) =>
                  s.single.tableId == 'table-1' &&
                  s.single.revenueSatang == 30000,
            ),
          ]),
        );

        await seedSale(tableId: 'table-1', price: 200);
        await done;
      },
    );

    test('watchCustomerOrderCounts emits initial then recomputes', () async {
      await db
          .into(db.customers)
          .insert(
            CustomersCompanion.insert(id: 'cust-1', name: 'Test Customer'),
          );
      final item = await seedProductItem();
      await saleDs.insertSaleWithItems(
        items: [item],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        customerId: 'cust-1',
      );

      final done = expectLater(
        queryDs.watchCustomerOrderCounts(),
        emitsInOrder([
          predicate<Map<String, int>>((m) => m['cust-1'] == 1),
          predicate<Map<String, int>>((m) => m['cust-1'] == 2),
        ]),
      );

      await saleDs.insertSaleWithItems(
        items: [item],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        customerId: 'cust-1',
      );
      await done;
    });

    test('watchSales applies from/to filters', () async {
      final saleId = await seedSale();

      final cutoff = DateTime.now().add(const Duration(seconds: 5));
      await expectLater(
        queryDs.watchSales(from: cutoff),
        emits(predicate<List<dynamic>>((s) => s.isEmpty)),
      );

      final stored = await (db.select(
        db.sales,
      )..where((t) => t.id.equals(saleId))).getSingle();
      expect(stored.createdAt.isBefore(cutoff), isTrue);
    });
  });

  group('querySalesPage search predicate', () {
    test('matches by product name', () async {
      await seedSale();

      final page = await queryDs.querySalesPage(searchQuery: 'pad tha');

      expect(page.sales, hasLength(1));
      expect(page.totalCount, 1);
    });

    test('matches by payment method', () async {
      await seedSale(paymentMethod: 'promptpay');

      final page = await queryDs.querySalesPage(searchQuery: 'promptpay');

      expect(page.sales, hasLength(1));
    });

    test('matches by total amount string', () async {
      await seedSale(price: 300);

      final page = await queryDs.querySalesPage(searchQuery: '300');

      expect(page.sales, hasLength(1));
    });

    test('returns nothing for a non-matching query', () async {
      await seedSale();

      final page = await queryDs.querySalesPage(searchQuery: 'zzz-none');

      expect(page.sales, isEmpty);
      expect(page.totalCount, 0);
    });

    test('blank query skips the predicate and returns all sales', () async {
      await seedSale();
      await seedSale();

      final page = await queryDs.querySalesPage(searchQuery: '   ');

      expect(page.sales, hasLength(2));
      expect(page.totalCount, 2);
      expect(page.nextCursor, isNull);
      expect(page.hasMore, isFalse);
    });
  });
}
