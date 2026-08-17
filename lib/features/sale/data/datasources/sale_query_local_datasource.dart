import 'package:drift/drift.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_helpers.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

/// Read/hydrate path for sales (query, watch, row → domain).
///
/// Owned by [SaleLocalDatasourceImpl]; not registered separately in DI.
class SaleQueryLocalDatasource {
  SaleQueryLocalDatasource(this._db);

  final AppDatabase _db;

  Sale buildSale(
    SaleData s,
    List<SaleItemData> items, {
    List<SalePaymentData> paymentRows = const [],
  }) => Sale(
    id: s.id,
    receiptNumber: s.receiptNumber,
    status: s.status,
    subtotalAmount: moneyFromSatangOrBaht(
      s.subtotalAmountSatang,
      s.subtotalAmount,
    ),
    discountType: s.discountType,
    discountValue: s.discountValueSatang?.value ?? s.discountValue,
    discountAmount: moneyFromSatangOrBaht(
      s.discountAmountSatang,
      s.discountAmount,
    ),
    vatMode: s.vatMode,
    vatRate: s.vatRate,
    vatAmount: moneyFromSatangOrBaht(s.vatAmountSatang, s.vatAmount),
    orderType: s.orderType,
    orderChannel: s.orderChannel,
    externalOrderRef: s.externalOrderRef,
    tableId: s.tableId,
    serviceChargeRate: s.serviceChargeRate,
    serviceChargeAmount: moneyFromSatangOrBaht(
      s.serviceChargeAmountSatang,
      s.serviceChargeAmount,
    ),
    customerId: s.customerId,
    promotionId: s.promotionId,
    promotionDiscountAmount: moneyFromSatangOrBaht(
      s.promotionDiscountAmountSatang,
      s.promotionDiscountAmount,
    ),
    totalAmount: moneyFromSatangOrBaht(s.totalAmountSatang, s.totalAmount),
    paymentMethod: s.paymentMethod,
    amountReceived: nullableMoneyFromSatangOrBaht(
      s.amountReceivedSatang,
      s.amountReceived,
    ),
    changeAmount: nullableMoneyFromSatangOrBaht(
      s.changeAmountSatang,
      s.changeAmount,
    ),
    note: s.note,
    paymentReference: s.paymentReference,
    sendingBankCode: s.sendingBankCode,
    voidedAt: s.voidedAt,
    voidReason: s.voidReason,
    createdAt: s.createdAt,
    payments: [
      for (final p in paymentRows)
        SalePayment(
          id: p.id,
          saleId: p.saleId,
          method: p.method,
          amount: moneyFromSatangOrBaht(p.amountSatang, p.amount),
          reference: p.reference,
          sendingBankCode: p.sendingBankCode,
          sortOrder: p.sortOrder,
        ),
    ],
    items: items
        .map(
          (i) => SaleItem(
            id: i.id,
            saleId: i.saleId,
            productId: i.productId,
            productName: i.productName,
            price: moneyFromSatangOrBaht(i.priceSatang, i.price),
            qty: i.qty,
            subtotal: moneyFromSatangOrBaht(i.subtotalSatang, i.subtotal),
            discountAmount: moneyFromSatangOrBaht(
              i.discountAmountSatang,
              i.discountAmount,
            ),
            vatAmount: moneyFromSatangOrBaht(i.vatAmountSatang, i.vatAmount),
            note: i.note,
            selectedOptions: SaleWriteHelpers.parseSelectedOptions(
              i.productOptionsJson,
            ),
            updatedAt: i.updatedAt,
            deletedAt: i.deletedAt,
            version: i.version,
            deviceId: i.deviceId,
          ),
        )
        .toList(),
  );

  Future<List<SaleItemData>> itemsForSale(String saleId) => (_db.select(
    _db.saleItems,
  )..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())).get();

  Future<List<SalePaymentData>> paymentsForSale(String saleId) =>
      (_db.select(_db.salePayments)
            ..where((t) => t.saleId.equals(saleId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<List<Sale>> querySales({DateTime? from, DateTime? to}) async {
    final query = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    final salesData = await query.get();
    return hydrateSales(salesData);
  }

  /// Total non-deleted sale count, optionally within a date range.
  Future<int> querySalesCount({DateTime? from, DateTime? to}) async {
    final countExpr = _db.sales.id.count();
    final query = _db.selectOnly(_db.sales)
      ..addColumns([countExpr])
      ..where(_db.sales.deletedAt.isNull());
    if (from != null) {
      query.where(_db.sales.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(_db.sales.createdAt.isSmallerOrEqualValue(to));
    }
    final result = await query.getSingle();
    return result.read(countExpr) ?? 0;
  }

  /// Cursor-paginated history page (createdAt DESC, id DESC).
  ///
  /// Items and payments are hydrated only for the sales on the current page,
  /// so memory is bounded by [pageSize], not by the report window. The
  /// optional [from]/[to] range is applied before pagination.
  Future<SalePage> querySalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
  }) async {
    final query = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    if (cursor != null) {
      query.where(
        (s) =>
            s.createdAt.isSmallerThanValue(cursor.createdAt) |
            (s.createdAt.equals(cursor.createdAt) &
                s.id.isSmallerThanValue(cursor.id)),
      );
    }
    query
      ..orderBy([
        (s) => OrderingTerm.desc(s.createdAt),
        (s) => OrderingTerm.desc(s.id),
      ])
      ..limit(pageSize + 1);
    final rows = await query.get();
    final hasMore = rows.length > pageSize;
    final pageRows = hasMore ? rows.sublist(0, pageSize) : rows;
    final sales = await hydrateSales(pageRows);
    final nextCursor = hasMore && pageRows.isNotEmpty
        ? SaleCursor(createdAt: pageRows.last.createdAt, id: pageRows.last.id)
        : null;
    final totalCount = await querySalesCount(from: from, to: to);
    return SalePage(
      sales: sales,
      nextCursor: nextCursor,
      totalCount: totalCount,
    );
  }

  /// SQL-aggregated report summary for a date range, computed without
  /// hydrating `List<Sale>` (no item-level data). Uses `*_satang` INTEGER
  /// columns (with REAL fallback) to preserve money SSOT.
  ///
  /// Mirrors [SalesPeriodTotals.from] for the fields derivable from the
  /// `sales` table. Payment breakdown prefers `sale_payments` rows when
  /// present, falling back to the header `payment_method` for legacy sales.
  /// Item-derived metrics (top products, profit) still require hydration.
  Future<ReportSummary> queryReportSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    final allSales = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      allSales.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      allSales.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    final salesRows = await allSales.get();
    final voidedRows = salesRows.where((s) => s.status == 'VOIDED').toList();
    final completedRows = salesRows.where((s) => s.status != 'VOIDED').toList();

    final netSatang = _sumSatang(
      completedRows,
      (s) => s.totalAmountSatang,
      (s) => s.totalAmount,
    );
    final voidedSatang = _sumSatang(
      voidedRows,
      (s) => s.totalAmountSatang,
      (s) => s.totalAmount,
    );
    final vatSatang = _sumSatang(
      completedRows,
      (s) => s.vatAmountSatang,
      (s) => s.vatAmount,
    );
    final discountSatang = _sumSatang(
      completedRows,
      (s) => s.discountAmountSatang,
      (s) => s.discountAmount,
    );
    final serviceChargeSatang = _sumSatang(
      completedRows,
      (s) => s.serviceChargeAmountSatang,
      (s) => s.serviceChargeAmount,
    );
    final promotionDiscountSatang = _sumSatang(
      completedRows,
      (s) => s.promotionDiscountAmountSatang,
      (s) => s.promotionDiscountAmount,
    );
    final promotionCount = completedRows
        .where((s) => s.promotionId != null || s.promotionDiscountAmount > 0)
        .length;

    // Payment breakdown + counts.
    final paymentBreakdownSatang = <String, int>{};
    final paymentCounts = <String, int>{};
    final saleIds = salesRows.map((s) => s.id).toSet();
    if (saleIds.isNotEmpty) {
      // Chunk the payment lookup to stay under SQLite's variable limit
      // (999 by default). 500 ids per batch is safe.
      const chunkSize = 500;
      final paymentRows = <SalePaymentData>[];
      final idList = saleIds.toList();
      for (var i = 0; i < idList.length; i += chunkSize) {
        final chunk = idList.sublist(
          i,
          (i + chunkSize).clamp(0, idList.length),
        );
        final rows =
            await (_db.select(_db.salePayments)
                  ..where((p) => p.saleId.isIn(chunk))
                  ..where((p) => p.deletedAt.isNull()))
                .get();
        paymentRows.addAll(rows);
      }
      // Group payments by saleId to know which sales have payment rows.
      final paymentsBySale = <String, List<SalePaymentData>>{};
      for (final p in paymentRows) {
        (paymentsBySale[p.saleId] ??= <SalePaymentData>[]).add(p);
      }
      for (final s in completedRows) {
        final legs = paymentsBySale[s.id];
        if (legs != null && legs.isNotEmpty) {
          for (final leg in legs) {
            final key = normalizePaymentMethod(leg.method);
            final sat =
                leg.amountSatang?.satang ?? Money.fromDouble(leg.amount).satang;
            paymentBreakdownSatang[key] =
                (paymentBreakdownSatang[key] ?? 0) + sat;
            paymentCounts[key] = (paymentCounts[key] ?? 0) + 1;
          }
        } else {
          final key = normalizePaymentMethod(s.paymentMethod);
          final sat =
              s.totalAmountSatang?.satang ??
              Money.fromDouble(s.totalAmount).satang;
          paymentBreakdownSatang[key] =
              (paymentBreakdownSatang[key] ?? 0) + sat;
          paymentCounts[key] = (paymentCounts[key] ?? 0) + 1;
        }
      }
    }

    // Order type / channel breakdowns (completed only).
    final orderTypeSatang = <String, int>{};
    final orderChannelSatang = <String, int>{};
    for (final s in completedRows) {
      final totalSat =
          s.totalAmountSatang?.satang ?? Money.fromDouble(s.totalAmount).satang;
      orderTypeSatang[s.orderType] =
          (orderTypeSatang[s.orderType] ?? 0) + totalSat;
      orderChannelSatang[s.orderChannel] =
          (orderChannelSatang[s.orderChannel] ?? 0) + totalSat;
    }

    // Void reason breakdown.
    final voidReasons = <String, int>{};
    for (final s in voidedRows) {
      final reason = s.voidReason?.trim();
      final key = reason == null || reason.isEmpty ? 'unspecified' : reason;
      voidReasons[key] = (voidReasons[key] ?? 0) + 1;
    }

    return ReportSummary(
      netRevenue: Money.fromSatang(netSatang),
      voidedTotal: Money.fromSatang(voidedSatang),
      salesCount: completedRows.length,
      voidCount: voidedRows.length,
      vatAmount: Money.fromSatang(vatSatang),
      discountAmount: Money.fromSatang(discountSatang),
      serviceChargeAmount: Money.fromSatang(serviceChargeSatang),
      promotionDiscountAmount: Money.fromSatang(promotionDiscountSatang),
      paymentBreakdown: {
        for (final e in paymentBreakdownSatang.entries) e.key: e.value / 100.0,
      },
      paymentCounts: Map.unmodifiable(paymentCounts),
      orderTypeBreakdown: {
        for (final e in orderTypeSatang.entries) e.key: e.value / 100.0,
      },
      orderChannelBreakdown: {
        for (final e in orderChannelSatang.entries) e.key: e.value / 100.0,
      },
      voidReasonBreakdown: Map.unmodifiable(voidReasons),
      promotionCount: promotionCount,
    );
  }

  int _sumSatang(
    List<SaleData> rows,
    Money? Function(SaleData) satangSelector,
    double Function(SaleData) bahtSelector,
  ) {
    var sum = 0;
    for (final r in rows) {
      final sat = satangSelector(r)?.satang;
      if (sat != null) {
        sum += sat;
      } else {
        sum += Money.fromDouble(bahtSelector(r)).satang;
      }
    }
    return sum;
  }

  Future<Sale?> querySaleById(String id) async {
    final s =
        await (_db.select(_db.sales)
              ..where((t) => t.id.equals(id))
              ..where((t) => t.deletedAt.isNull()))
            .getSingleOrNull();
    if (s == null) return null;
    final items = await itemsForSale(id);
    final paymentRows = await paymentsForSale(id);
    return buildSale(s, items, paymentRows: paymentRows);
  }

  Stream<List<Sale>> watchRecentSales({int limit = 20}) {
    final query = _db.select(_db.sales)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit);
    return query.watch().asyncMap(hydrateSales);
  }

  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) {
    final query = _db.select(_db.sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.orderBy([(s) => OrderingTerm.desc(s.createdAt)]);
    return query.watch().asyncMap(hydrateSales);
  }

  /// Batch-load items + payments for [salesData] and map to domain.
  Future<List<Sale>> hydrateSales(List<SaleData> salesData) async {
    if (salesData.isEmpty) return [];
    final saleIds = salesData.map((s) => s.id).toList();
    final allItems = await (_db.select(
      _db.saleItems,
    )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
    final itemsBySaleId = <String, List<SaleItemData>>{};
    for (final item in allItems) {
      (itemsBySaleId[item.saleId] ??= []).add(item);
    }
    final allPays = await (_db.select(
      _db.salePayments,
    )..where((t) => t.saleId.isIn(saleIds) & t.deletedAt.isNull())).get();
    final paysBySaleId = <String, List<SalePaymentData>>{};
    for (final pay in allPays) {
      (paysBySaleId[pay.saleId] ??= []).add(pay);
    }
    return salesData
        .map(
          (s) => buildSale(
            s,
            itemsBySaleId[s.id] ?? [],
            paymentRows: paysBySaleId[s.id] ?? const [],
          ),
        )
        .toList();
  }
}
