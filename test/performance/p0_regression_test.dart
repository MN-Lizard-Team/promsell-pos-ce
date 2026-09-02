// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_page.dart';
import 'package:promsell_pos_ce/features/report/data/services/report_export_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

import '../helpers/fake_app_lock.dart';
import '../helpers/scaling_fixture.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleQueryLocalDatasource saleQuery;
  late SaleRepositoryImpl saleRepo;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p0_regression_');
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    db = createFileBackedDatabase(tempDir, name: 'p0_regression.db');
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
    saleQuery = SaleQueryLocalDatasource(db);
    final fakeDs = _FakeSaleLocalDatasource(saleQuery);
    saleRepo = SaleRepositoryImpl(fakeDs);
  });

  tearDown(() async => db.close());

  Future<void> seedBaseline() async {
    final sw = Stopwatch()..start();
    final counts = await seedScalingFixture(db);
    print('  Seeded $counts in ${sw.elapsedMilliseconds}ms');
  }

  group('P0 regression: product search beyond first page', () {
    test(
      'DB search finds products beyond the in-memory 500-row window',
      () async {
        await seedBaseline();
        // Product 1999 has sku 'SKU1999' — would be missed by an in-memory
        // filter that only loads the first 500 products.
        final page = await productDs.searchProductsPage(
          query: 'SKU1999',
          pageSize: 50,
        );
        expect(page.products, hasLength(1));
        expect(page.products.first.id, 'prod-scale-1999');
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'DB search by name returns ranked page',
      () async {
        await seedBaseline();
        final page = await productDs.searchProductsPage(
          query: 'Product 1',
          pageSize: 50,
        );
        expect(page.products, isNotEmpty);
        // All matches should contain 'product 1' in name/sku/barcode.
        expect(
          page.products.every(
            (p) => p.name.toLowerCase().contains('product 1'),
          ),
          isTrue,
        );
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });

  group('P0 regression: product pagination stability', () {
    test(
      'cursor pagination covers all 2k products without overlap',
      () async {
        await seedBaseline();
        final seen = <String>{};
        ProductCursor? cursor;
        var pages = 0;
        while (true) {
          final page = await productDs.getProductsPage(
            cursor: cursor,
            pageSize: kProductPageSize,
          );
          pages++;
          for (final p in page.products) {
            expect(seen, isNot(contains(p.id)), reason: 'duplicate ${p.id}');
            seen.add(p.id);
          }
          cursor = page.nextCursor;
          if (!page.hasMore) break;
        }
        expect(seen.length, kBaselineProductCount);
        expect(pages, greaterThan(1));
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'pagination is stable across soft-deletes',
      () async {
        await seedBaseline();
        // Soft-delete 10 products in the middle of the catalog.
        final toDelete = List.generate(10, (i) => 'prod-scale-${1000 + i}');
        await db.batch((b) {
          for (final id in toDelete) {
            b.update(
              db.products,
              ProductsCompanion(
                deletedAt: Value(DateTime.now()),
                updatedAt: Value(DateTime.now()),
              ),
              where: (p) => p.id.equals(id),
            );
          }
        });
        final seen = <String>{};
        ProductCursor? cursor;
        while (true) {
          final page = await productDs.getProductsPage(
            cursor: cursor,
            pageSize: kProductPageSize,
          );
          for (final p in page.products) {
            expect(seen, isNot(contains(p.id)));
            seen.add(p.id);
          }
          cursor = page.nextCursor;
          if (!page.hasMore) break;
        }
        // 2000 - 10 soft-deleted = 1990 visible.
        expect(seen.length, kBaselineProductCount - 10);
        // None of the soft-deleted ids should appear.
        for (final id in toDelete) {
          expect(seen, isNot(contains(id)));
        }
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });

  group('P0 regression: year-range report summary', () {
    test(
      'report summary covers a 2-year range without hydration',
      () async {
        await seedBaseline();
        final sw = Stopwatch()..start();
        final summary = await saleQuery.queryReportSummary(
          from: DateTime(2024, 1, 1),
          to: DateTime(2025, 12, 31, 23, 59, 59),
        );
        print('  Report summary in ${sw.elapsedMilliseconds}ms');
        expect(summary.salesCount, kBaselineSaleCount);
        expect(summary.netRevenue.isPositive, isTrue);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'report summary for 2024 only excludes 2025 sales',
      () async {
        await seedBaseline();
        final summary2024 = await saleQuery.queryReportSummary(
          from: DateTime(2024, 1, 1),
          to: DateTime(2024, 12, 31, 23, 59, 59),
        );
        final summary2025 = await saleQuery.queryReportSummary(
          from: DateTime(2025, 1, 1),
          to: DateTime(2025, 12, 31, 23, 59, 59),
        );
        expect(
          summary2024.salesCount + summary2025.salesCount,
          kBaselineSaleCount,
        );
        expect(summary2024.salesCount, greaterThan(0));
        expect(summary2025.salesCount, greaterThan(0));
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });

  group('P0 regression: bounded streaming export', () {
    test(
      'export caps at kExportMaxRows on 50k-sale fixture',
      () async {
        await seedBaseline();
        final exportService = ReportExportService(fakeAppLock());
        final sw = Stopwatch()..start();
        final chunks = <String>[];
        final result = await exportService.exportCsvStream(
          saleRepository: saleRepo,
          sink: chunks.add,
          pageSize: 500,
          maxRows: kExportMaxRows,
        );
        print(
          '  Export ${result.rowsWritten} rows in ${sw.elapsedMilliseconds}ms '
          '(truncated=${result.truncated})',
        );
        expect(result.rowsWritten, kExportMaxRows);
        expect(result.truncated, isTrue);
        // Memory bound: we never hold more than one page (500 rows) + buffer.
        // The number of chunks should be roughly maxRows / pageSize.
        expect(chunks.length, lessThanOrEqualTo(50));
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );

    test(
      'export startSignal resolves before first data row',
      () async {
        await seedBaseline();
        final exportService = ReportExportService(fakeAppLock());
        var signalFired = false;
        var chunksBeforeSignal = 0;
        await exportService.exportCsvStream(
          saleRepository: saleRepo,
          sink: (chunk) {
            if (!signalFired) chunksBeforeSignal++;
          },
          pageSize: 500,
          maxRows: 100,
          startSignal: () async {
            signalFired = true;
          },
        );
        // Only the header chunk is written before startSignal.
        expect(chunksBeforeSignal, 1);
        expect(signalFired, isTrue);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );
  });

  group('P0 regression: paged history hydration', () {
    test(
      'history page hydrates items only for the current page',
      () async {
        await seedBaseline();
        final sw = Stopwatch()..start();
        final page = await saleQuery.querySalesPage(
          pageSize: kSaleHistoryPageSize,
        );
        print('  History page in ${sw.elapsedMilliseconds}ms');
        expect(page.sales, hasLength(kSaleHistoryPageSize));
        expect(page.totalCount, kBaselineSaleCount);
        // Each sale should have items hydrated.
        expect(page.sales.first.items, isNotEmpty);
      },
      timeout: const Timeout(Duration(minutes: 5)),
    );

    test(
      'history pagination covers all 50k sales',
      () async {
        await seedBaseline();
        final seen = <String>{};
        SaleCursor? cursor;
        while (true) {
          final page = await saleQuery.querySalesPage(
            cursor: cursor,
            pageSize: kSaleHistoryPageSize,
          );
          for (final s in page.sales) {
            expect(seen, isNot(contains(s.id)));
            seen.add(s.id);
          }
          cursor = page.nextCursor;
          if (!page.hasMore) break;
        }
        expect(seen.length, kBaselineSaleCount);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );
  });
}

class _FakeSaleLocalDatasource implements SaleLocalDatasource {
  _FakeSaleLocalDatasource(this._query);
  final SaleQueryLocalDatasource _query;

  @override
  Future<SalePage> querySalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
    String? searchQuery,
  }) => _query.querySalesPage(
    from: from,
    to: to,
    cursor: cursor,
    pageSize: pageSize,
    searchQuery: searchQuery,
  );

  @override
  Future<int> querySalesCount({
    DateTime? from,
    DateTime? to,
    String? searchQuery,
  }) => _query.querySalesCount(from: from, to: to, searchQuery: searchQuery);

  @override
  Future<ReportSummary> queryReportSummary({DateTime? from, DateTime? to}) =>
      _query.queryReportSummary(from: from, to: to);

  @override
  Stream<ReportAggregate> watchReportAggregate({
    DateTime? from,
    DateTime? to,
  }) => _query.watchReportAggregate(from: from, to: to);

  @override
  Future<Sale> insertSaleWithItems({
    required List<CartItem> items,
    required String paymentMethod,
    required String vatMode,
    required double vatRate,
    String? cartDiscountType,
    double? cartDiscountValue,
    Money? cartDiscountAmount,
    Money? amountReceived,
    Money? changeAmount,
    String? note,
    String? paymentReference,
    String? sendingBankCode,
    List<SalePayment>? payments,
    String orderType = 'delivery',
    String orderChannel = 'walkin',
    String? externalOrderRef,
    String? tableId,
    double serviceChargeRate = 0.0,
    Money serviceChargeAmount = Money.zero,
    String? customerId,
    String? promotionId,
    Money promotionDiscountAmount = Money.zero,
    String? originatingDraftCartId,
    List<String>? selectedItemIds,
  }) => throw UnimplementedError();

  @override
  Future<List<Sale>> querySales({DateTime? from, DateTime? to}) =>
      _query.querySales(from: from, to: to);

  @override
  Future<Sale?> querySaleById(String id) => _query.querySaleById(id);

  @override
  Stream<List<Sale>> watchRecentSales({int limit = 20}) =>
      _query.watchRecentSales(limit: limit);

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _query.watchSales(from: from, to: to);

  @override
  Future<void> voidSale(String saleId, {String? reason}) =>
      throw UnimplementedError();
}
