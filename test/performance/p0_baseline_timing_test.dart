// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/report/data/services/report_export_service.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

import '../helpers/fake_app_lock.dart';
import '../helpers/scaling_fixture.dart';

/// Baseline timings on the desktop file-backed fixture (2k products / 50k
/// sales / 250k items). These are NOT device-accurate — they validate query
/// plans and provide a CI trend signal. On-device p95 targets are defined
/// in the SLO table of `ce-scaling-management-plan.md`; checkout, backup,
/// and migration baselines require the real SQLCipher library and are
/// measured by the P1 integration_test suite.
void main() {
  late Directory tempDir;
  late AppDatabase db;
  late ProductLocalDatasourceImpl productDs;
  late SaleQueryLocalDatasource saleQuery;
  late SaleRepositoryImpl saleRepo;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('p0_baseline_');
    registerFakePathProvider(tempDir);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  setUp(() async {
    db = createFileBackedDatabase(tempDir, name: 'p0_baseline.db');
    productDs = ProductLocalDatasourceImpl(db, ProductOptionDatasourceImpl(db));
    saleQuery = SaleQueryLocalDatasource(db);
    saleRepo = SaleRepositoryImpl(_FakeSaleDs(saleQuery));
  });

  tearDown(() async => db.close());

  Future<int> timeOp(String label, Future<void> Function() op) async {
    final sw = Stopwatch()..start();
    await op();
    final ms = sw.elapsedMilliseconds;
    print('  $label: ${ms}ms');
    return ms;
  }

  test(
    'baseline timings on 2k/50k fixture',
    () async {
      await timeOp('seed', () async {
        await seedScalingFixture(db);
      });

      // Catalog first page (SLO target <500ms on-device).
      final catalogMs = await timeOp('catalog first page', () async {
        final page = await productDs.getProductsPage(
          pageSize: kProductPageSize,
        );
        expect(page.products, hasLength(kProductPageSize));
      });
      expect(catalogMs, lessThan(500), reason: 'catalog first page too slow');

      // Catalog search after debounce (SLO target <500ms on-device).
      final searchMs = await timeOp('catalog search', () async {
        final page = await productDs.searchProductsPage(
          query: 'Product 99',
          pageSize: kProductPageSize,
        );
        expect(page.products, isNotEmpty);
      });
      expect(searchMs, lessThan(500), reason: 'catalog search too slow');

      // Barcode lookup (SLO target <150ms on-device).
      final barcodeMs = await timeOp('barcode lookup', () async {
        final p = await productDs.getProductByBarcode('BC1999');
        expect(p, isNotNull);
        expect(p!.id, 'prod-scale-1999');
      });
      expect(barcodeMs, lessThan(150), reason: 'barcode lookup too slow');

      // SKU lookup (SLO target <150ms on-device).
      final skuMs = await timeOp('sku lookup', () async {
        final p = await productDs.getProductBySku('SKU1999');
        expect(p, isNotNull);
        expect(p!.id, 'prod-scale-1999');
      });
      expect(skuMs, lessThan(150), reason: 'sku lookup too slow');

      // History first page (SLO target <800ms on-device).
      final historyMs = await timeOp('history first page', () async {
        final page = await saleQuery.querySalesPage(
          pageSize: kSaleHistoryPageSize,
        );
        expect(page.sales, hasLength(kSaleHistoryPageSize));
        expect(page.totalCount, kBaselineSaleCount);
      });
      expect(historyMs, lessThan(800), reason: 'history first page too slow');

      // Daily report summary — today only (SLO target <1s on-device).
      final dailyMs = await timeOp('daily report summary', () async {
        final summary = await saleQuery.queryReportSummary(
          from: DateTime(2024, 1, 1),
          to: DateTime(2024, 1, 1, 23, 59, 59),
        );
        expect(summary.salesCount, greaterThan(0));
      });
      expect(dailyMs, lessThan(1000), reason: 'daily report summary too slow');

      // Year report summary (SLO target <3s on-device).
      final yearMs = await timeOp('year report summary', () async {
        final summary = await saleQuery.queryReportSummary(
          from: DateTime(2024, 1, 1),
          to: DateTime(2024, 12, 31, 23, 59, 59),
        );
        expect(summary.salesCount, greaterThan(0));
      });
      expect(yearMs, lessThan(3000), reason: 'year report summary too slow');

      // Export start feedback (SLO target <500ms on-device).
      final exportService = ReportExportService(fakeAppLock());
      var signalFired = false;
      final exportSw = Stopwatch()..start();
      await exportService.exportCsvStream(
        saleRepository: saleRepo,
        sink: (_) {},
        pageSize: 500,
        maxRows: 100,
        startSignal: () async {
          signalFired = true;
        },
      );
      final exportStartMs = exportSw.elapsedMilliseconds;
      print('  export start feedback: ${exportStartMs}ms');
      expect(signalFired, isTrue);
      expect(
        exportStartMs,
        lessThan(500),
        reason: 'export start feedback too slow',
      );

      print(
        '  --- baseline summary (desktop fixture, not device-accurate) ---',
      );
      print('  catalog first page:   ${catalogMs}ms (SLO <500ms)');
      print('  catalog search:       ${searchMs}ms (SLO <500ms)');
      print('  barcode lookup:       ${barcodeMs}ms (SLO <150ms)');
      print('  sku lookup:           ${skuMs}ms (SLO <150ms)');
      print('  history first page:   ${historyMs}ms (SLO <800ms)');
      print('  daily report summary: ${dailyMs}ms (SLO <1s)');
      print('  year report summary:  ${yearMs}ms (SLO <3s)');
      print('  export start:         ${exportStartMs}ms (SLO <500ms)');
      print(
        '  checkout/backup/migration: deferred to P1 on-device integration_test',
      );
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

class _FakeSaleDs implements SaleLocalDatasource {
  _FakeSaleDs(this._query);
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
