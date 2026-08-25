import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/inventory/data/services/inventory_log_service.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/data/services/receipt_number_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/get_sales_page.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_settings_repository.dart';

/// Coverage for the SQL aggregate query surface added with the report
/// pipeline refactor (`watchReportAggregate` and friends). Every method runs
/// against a fixture spanning: completed cash + promptpay bills (with tender
/// legs), a legacy header-only promptpay bill, a voided sale, customers,
/// products with / without / soft-deleted cost data.
void main() {
  late AppDatabase db;
  late SaleQueryLocalDatasource query;

  final day1 = DateTime(2025, 3, 1, 9); // hour-of-day bucket 9
  final day2 = DateTime(2025, 3, 2, 14); // hour-of-day bucket 14

  setUp(() {
    db = createInMemoryDatabase();
    query = SaleQueryLocalDatasource(db);
  });

  tearDown(() => db.close());

  Future<void> seedFixture() async {
    await db.batch((b) {
      // Products: with cost / without cost / soft-deleted.
      b.insert(
        db.products,
        ProductsCompanion.insert(
          id: 'p1',
          name: 'Latte',
          price: 60,
          cost: const Value(30.0),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );
      b.insert(
        db.products,
        ProductsCompanion.insert(
          id: 'p2',
          name: 'Tea',
          price: 40,
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );
      b.insert(
        db.products,
        ProductsCompanion.insert(
          id: 'p3',
          name: 'Old Cake',
          price: 80,
          deletedAt: Value(day1),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );

      // s1 — day1 09:00 cash, customer c1, item p1 x1 (60).
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's1',
          totalAmount: 60.0,
          paymentMethod: 'cash',
          customerId: const Value('c1'),
          createdAt: Value(day1),
          updatedAt: Value(day1),
          totalAmountSatang: Value(Money.fromDouble(60.0)),
        ),
      );
      // s2 — day2 14:00 promptpay legs, customer c1 again, p2 x2 (80)
      // + p3 x1 (80) where p3 is soft-deleted on the product side.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's2',
          totalAmount: 160.0,
          paymentMethod: 'promptpay',
          customerId: const Value('c1'),
          createdAt: Value(day2),
          updatedAt: Value(day2),
          totalAmountSatang: Value(Money.fromDouble(160.0)),
        ),
      );
      // s3 — legacy header-only promptpay bill (no tender rows), day1 noon.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's3',
          totalAmount: 90.0,
          paymentMethod: 'promptpay',
          createdAt: Value(day1.add(const Duration(hours: 3))),
          updatedAt: Value(day1.add(const Duration(hours: 3))),
          totalAmountSatang: Value(Money.fromDouble(90.0)),
        ),
      );
      // s4 — voided; excluded from every completed-only metric below.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's4',
          status: const Value('VOIDED'),
          totalAmount: 500.0,
          paymentMethod: 'cash',
          voidReason: const Value('mistake'),
          createdAt: Value(day2),
          updatedAt: Value(day2),
          totalAmountSatang: Value(Money.fromDouble(500.0)),
        ),
      );

      b.insert(
        db.saleItems,
        SaleItemsCompanion.insert(
          id: 'i1',
          saleId: 's1',
          productId: 'p1',
          productName: 'Latte',
          price: 60,
          qty: 1,
          subtotal: 60,
          subtotalSatang: Value(Money.fromDouble(60)),
        ),
      );
      b.insert(
        db.saleItems,
        SaleItemsCompanion.insert(
          id: 'i2',
          saleId: 's2',
          productId: 'p2',
          productName: 'Tea',
          price: 40,
          qty: 2,
          subtotal: 80,
          subtotalSatang: Value(Money.fromDouble(80)),
        ),
      );
      b.insert(
        db.saleItems,
        SaleItemsCompanion.insert(
          id: 'i3',
          saleId: 's2',
          productId: 'p3',
          productName: 'Old Cake',
          price: 80,
          qty: 1,
          subtotal: 80,
          subtotalSatang: Value(Money.fromDouble(80)),
        ),
      );

      b.insert(
        db.salePayments,
        SalePaymentsCompanion.insert(
          id: 'pay1',
          saleId: 's1',
          method: 'cash',
          amount: 60.0,
          amountSatang: Value(Money.fromDouble(60.0)),
        ),
      );
      b.insert(
        db.salePayments,
        SalePaymentsCompanion.insert(
          id: 'pay2',
          saleId: 's2',
          method: 'promptpay',
          amount: 160.0,
          amountSatang: Value(Money.fromDouble(160.0)),
        ),
      );
    });
  }

  group('daily revenue', () {
    test(
      'zero-fills calendar days, excludes voided, counts completed only',
      () async {
        await seedFixture();
        final daily = await query.queryDailyRevenue(
          from: DateTime(2025, 3, 1),
          to: DateTime(2025, 3, 4, 23, 59, 59),
        );
        expect(daily, hasLength(4));
        expect(daily[0].revenue, closeTo(150.0, 0.001)); // s1 60 + s3 90
        expect(daily[0].count, 2);
        expect(daily[1].revenue, closeTo(160.0, 0.001)); // s2 (s4 voided)
        expect(daily[1].count, 1);
        for (final empty in daily.sublist(2)) {
          expect(empty.revenue, 0.0);
          expect(empty.count, 0);
        }
      },
    );

    test('watch emits the current aggregation as its first value', () async {
      await seedFixture();
      final first = await query.watchDailyRevenue().first;
      expect(first.first.revenue, closeTo(150.0, 0.001));
    });
  });

  group('hourly revenue', () {
    test('groups into local hour buckets in baht', () async {
      await seedFixture();
      final hourly = await query.queryHourlyRevenue();
      expect(hourly[9], closeTo(60.0, 0.001)); // s1
      expect(hourly[12], closeTo(90.0, 0.001)); // s3 (day1 + 3h)
      expect(hourly[14], closeTo(160.0, 0.001)); // s2
      expect(hourly.containsKey(8), isFalse);
    });

    test('watch emits immediately', () async {
      await seedFixture();
      final first = await query.watchHourlyRevenue().first;
      expect(first[14], closeTo(160.0, 0.001));
    });
  });

  group('top products', () {
    test('ranks by qty and joins live product cost', () async {
      await seedFixture();
      final tops = await query.queryTopProductStats(limit: 5);
      expect(tops.first.displayName, 'Tea');
      expect(tops.first.qty, 2);
      expect(tops.first.revenue, closeTo(80.0, 0.001));

      final latte = tops.singleWhere((t) => t.displayName == 'Latte');
      expect(latte.qty, 1);
      expect(latte.revenue, closeTo(60.0, 0.001));
      expect(latte.cost, closeTo(30.0, 0.001));
      expect(latte.profit, closeTo(30.0, 0.001));
      expect(latte.marginPercent, closeTo(50.0, 0.01));
    });

    test('respects the limit parameter', () async {
      await seedFixture();
      expect(await query.queryTopProductStats(limit: 1), hasLength(1));
    });

    test('watch variant emits ranked stats', () async {
      await seedFixture();
      final tops = await query.watchTopProductStats().first;
      expect(tops.first.qty, 2);
    });
  });

  group('profit analytics', () {
    test('sums line satang and splits cost coverage', () async {
      await seedFixture();
      final profit = await query.queryProfitAnalytics();
      expect(profit!.totalCost.value, closeTo(30.0, 0.001)); // p1 only
      expect(profit.grossProfit.value, closeTo(190.0, 0.001)); // 220 - 30
      expect(profit.itemsWithCost, 1);
      expect(profit.itemsWithoutCost, 2);
    });

    test('watch variant emits analytics', () async {
      await seedFixture();
      final profit = await query.watchProfitAnalytics().first;
      expect(profit!.itemsWithCost, 1);
    });
  });

  group('customer counts', () {
    test('counts completed orders per customer only', () async {
      await seedFixture();
      final counts = await query.queryCustomerOrderCounts();
      expect(counts['c1'], 2);
      expect(counts.length, 1); // s3/s4 have no customer
    });

    test(
      'watch variant exposes repeat buyers through the aggregate bundle',
      () async {
        await seedFixture();
        final agg = await query.watchReportAggregate().first;
        expect(agg, isA<ReportAggregate>());
        expect(agg.uniqueCustomers, 1);
        expect(agg.repeatCustomers, 1); // c1 appears twice
        expect(agg.topProducts, isNotEmpty);
        expect(agg.profit, isNotNull);
        expect(agg.promptPayLegTotal.value, greaterThan(0));
        expect(agg.dailyRevenue, isNotEmpty);
        expect(agg.hourlyRevenue, isNotEmpty);
      },
    );
  });

  group('PromptPay stats', () {
    test('sums tender legs plus legacy header-only bills', () async {
      await seedFixture();
      final (legTotalSatang, billCount) = await query.queryPromptPayStats();
      expect(legTotalSatang, 25000); // s2 legs 16000 + header-only s3 9000
      expect(billCount, 2);
    });

    test(
      'recent bills include leg and legacy header variants, newest first',
      () async {
        await seedFixture();
        final recent = await query.queryRecentPromptPaySales();
        expect(recent.map((s) => s.id).toList(), ['s2', 's3']);
      },
    );
  });

  group('report summary watch', () {
    test(
      'watchReportSummary emits an aggregated summary immediately',
      () async {
        await seedFixture();
        final summary = await query.watchReportSummary().first;
        expect(summary.salesCount, 3); // s1 + s2 + s3 (s4 voided)
        expect(summary.netRevenue.value, closeTo(310.0, 0.001));
      },
    );
  });

  group('GetSalesPage usecase', () {
    test('delegates to repository cursor pagination without overlap', () async {
      await seedFixture();
      final settings = FakeSettingsRepository();
      final datasource = SaleLocalDatasourceImpl(
        db,
        receiptNumberService: ReceiptNumberService(db),
        inventoryLogService: InventoryLogService(db, settingsRepo: settings),
        settingsRepo: settings,
      );
      final repository = SaleRepositoryImpl(datasource);
      final usecase = GetSalesPage(repository);

      final pageOne = await usecase(pageSize: 2);
      expect(pageOne.sales, hasLength(2));
      expect(pageOne.totalCount, 4);
      expect(pageOne.nextCursor, isNotNull);

      final pageTwo = await usecase(cursor: pageOne.nextCursor, pageSize: 2);
      final ids = {
        ...pageOne.sales.map((s) => s.id),
        ...pageTwo.sales.map((s) => s.id),
      };
      expect(ids.length, 4, reason: 'cursor pages must not overlap');
    });

    test('SalePage.hasMore derives from the cursor presence', () {
      final withCursor = SalePage(
        sales: const [],
        nextCursor: SaleCursor(createdAt: DateTime(2025), id: 'c'),
        totalCount: 1,
      );
      expect(withCursor.hasMore, isTrue);

      const exhausted = SalePage(sales: [], nextCursor: null, totalCount: 0);
      expect(exhausted.hasMore, isFalse);
    });
  });
}
