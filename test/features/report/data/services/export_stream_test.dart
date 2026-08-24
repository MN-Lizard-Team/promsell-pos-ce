import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/data/services/report_export_service.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';

import '../../../../helpers/fake_database.dart';
import '../../../../helpers/fake_app_lock.dart';

void main() {
  late AppDatabase db;
  late SaleRepositoryImpl repo;
  late ReportExportService exportService;

  setUp(() {
    db = createInMemoryDatabase();
    final query = SaleQueryLocalDatasource(db);
    final datasource = _FakeSaleLocalDatasource(query);
    repo = SaleRepositoryImpl(datasource);
    exportService = ReportExportService(fakeAppLock());
  });

  tearDown(() => db.close());

  Future<void> seedSales(int count) async {
    final base = DateTime(2025, 1, 1);
    await db.batch((b) {
      for (var s = 0; s < count; s++) {
        final id = 'sale-$s';
        final date = base.add(Duration(minutes: s));
        b.insert(
          db.sales,
          SalesCompanion.insert(
            id: id,
            receiptNumber: Value('R$s'),
            totalAmount: (s % 100) + 1.0,
            paymentMethod: 'cash',
            createdAt: Value(date),
            updatedAt: Value(date),
          ),
        );
        b.insert(
          db.saleItems,
          SaleItemsCompanion.insert(
            id: 'si-$s-0',
            saleId: id,
            productId: 'p1',
            productName: 'Product 1',
            price: 10.0,
            qty: 1,
            subtotal: 10.0,
          ),
        );
      }
    });
  }

  group('exportCsvStream', () {
    test('writes all rows when under cap', () async {
      await seedSales(120);
      final chunks = <String>[];
      final result = await exportService.exportCsvStream(
        saleRepository: repo,
        sink: chunks.add,
        pageSize: 50,
      );
      expect(result.rowsWritten, 120);
      expect(result.truncated, isFalse);
      // Header + at least one data chunk.
      expect(chunks, isNotEmpty);
      final all = chunks.join();
      expect(all, contains('Receipt Number'));
      expect(all, contains('R0'));
      expect(all, contains('R119'));
    });

    test('truncates at maxRows cap', () async {
      await seedSales(150);
      final chunks = <String>[];
      final result = await exportService.exportCsvStream(
        saleRepository: repo,
        sink: chunks.add,
        pageSize: 50,
        maxRows: 100,
      );
      expect(result.rowsWritten, 100);
      expect(result.truncated, isTrue);
    });

    test('startSignal resolves before first data row', () async {
      await seedSales(10);
      var signalFired = false;
      var rowsBeforeSignal = 0;
      final result = await exportService.exportCsvStream(
        saleRepository: repo,
        sink: (chunk) {
          if (!signalFired) rowsBeforeSignal++;
        },
        pageSize: 50,
        startSignal: () async {
          signalFired = true;
        },
      );
      expect(result.rowsWritten, 10);
      // The header chunk is written before startSignal, so rowsBeforeSignal
      // counts only the header (1). No data rows before the signal.
      expect(rowsBeforeSignal, 1);
      expect(signalFired, isTrue);
    });

    test('empty range writes only header', () async {
      await seedSales(10);
      final chunks = <String>[];
      final result = await exportService.exportCsvStream(
        saleRepository: repo,
        sink: chunks.add,
        from: DateTime(2030, 1, 1),
        to: DateTime(2030, 1, 2),
      );
      expect(result.rowsWritten, 0);
      expect(result.truncated, isFalse);
      expect(chunks, hasLength(1));
      expect(chunks.single, contains('Receipt Number'));
    });
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
  }) => _query.querySalesPage(
    from: from,
    to: to,
    cursor: cursor,
    pageSize: pageSize,
  );

  @override
  Future<int> querySalesCount({DateTime? from, DateTime? to}) =>
      _query.querySalesCount(from: from, to: to);

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
