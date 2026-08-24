import 'package:drift/drift.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/top_product_stat.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_helpers.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

/// Read/hydrate path for sales (query, watch, SQL aggregates, row → domain).
///
/// Owned by [SaleLocalDatasourceImpl]; also registered as a lazy singleton so
/// the report data layer can run bounded aggregate queries. Read-only — all
/// writes go through [SaleLocalDatasourceImpl]'s writer collaborators.
class SaleQueryLocalDatasource {
  SaleQueryLocalDatasource(this._db);

  final AppDatabase _db;

  /// Newest PromptPay bills hydrated per aggregate emission (display list).
  static const kRecentPromptPayBillLimit = 5;

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
    final result =
        await (_db.selectOnly(_db.sales)
              ..addColumns([countExpr])
              ..where(_salesRange(from: from, to: to)))
            .getSingle();
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

  // ---------------------------------------------------------------------------
  // SQL aggregation (satang SSOT — no List<Sale> hydration).
  //
  // Money semantics mirror the established `moneyFromSatangOrBaht` reader:
  // satang column present → used as-is; NULL (legacy row) →
  // CAST(ROUND(baht * 100) AS INTEGER). SQLite's ROUND is half-away-from-zero
  // and both engines compute `baht * 100` in IEEE-754 doubles first, so the
  // fallback is bit-identical to `Money.fromDouble`. Every aggregate below is
  // computed by SQLite; Dart only maps grouped rows to domain objects.
  // ---------------------------------------------------------------------------

  /// SQL-aggregated report summary for a date range (`SUM(CASE …)` /
  /// `GROUP BY` over `sales` + `sale_payments`). Never hydrates `List<Sale>`
  /// and never loads item-level data.
  ///
  /// Payment breakdown prefers `sale_payments` legs when present and falls
  /// back to the header `payment_method`/total for legacy sales without
  /// tender lines — same rule as `SalesPeriodTotals.from`.
  Future<ReportSummary> queryReportSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    final headerRow = await _readSummaryHeader(from: from, to: to);

    final paymentBreakdownSatang = <String, int>{};
    final paymentCounts = <String, int>{};
    void accumulate(String? key, int satang, int count) {
      if (key == null) return;
      paymentBreakdownSatang[key] = (paymentBreakdownSatang[key] ?? 0) + satang;
      paymentCounts[key] = (paymentCounts[key] ?? 0) + count;
    }

    // Tender legs grouped by normalized method.
    final legMethodKey = _normalizedMethodExpr(_payCol('method'));
    final legSum = CustomExpression<int>(
      'SUM(${_moneySatangSql(_payCol('amount_satang'), _payCol('amount'))})',
    );
    final legCount = countAll();
    for (final row
        in await (_db.selectOnly(_db.sales)
              ..addColumns([legMethodKey, legSum, legCount])
              ..join([
                innerJoin(
                  _db.salePayments,
                  _db.salePayments.saleId.equalsExp(_db.sales.id),
                ),
              ])
              ..where(
                _db.salePayments.deletedAt.isNull() &
                    _salesRange(from: from, to: to) &
                    _notVoidedExpr(),
              )
              ..groupBy([legMethodKey]))
            .get()) {
      accumulate(
        row.read(legMethodKey),
        row.read(legSum) ?? 0,
        row.read(legCount) ?? 0,
      );
    }

    // Legacy header-only sales (no non-deleted tender lines).
    final headerMethodKey = _normalizedMethodExpr(_salesCol('payment_method'));
    final headerTotalSum = CustomExpression<int>(
      'SUM(${_moneySatangSql(_salesCol('total_amount_satang'), _salesCol('total_amount'))})',
    );
    final headerCount = countAll();
    for (final row
        in await (_db.selectOnly(_db.sales)
              ..addColumns([headerMethodKey, headerTotalSum, headerCount])
              ..join([
                leftOuterJoin(
                  _db.salePayments,
                  _db.salePayments.saleId.equalsExp(_db.sales.id) &
                      _db.salePayments.deletedAt.isNull(),
                ),
              ])
              ..where(
                _db.salePayments.id.isNull() &
                    _salesRange(from: from, to: to) &
                    _notVoidedExpr(),
              )
              ..groupBy([headerMethodKey]))
            .get()) {
      accumulate(
        row.read(headerMethodKey),
        row.read(headerTotalSum) ?? 0,
        row.read(headerCount) ?? 0,
      );
    }

    // Order type / channel breakdowns (completed only).
    final orderTypeSatang = await _sumTotalsGrouped(
      groupColumnSql: _salesCol('order_type'),
      from: from,
      to: to,
    );
    final orderChannelSatang = await _sumTotalsGrouped(
      groupColumnSql: _salesCol('order_channel'),
      from: from,
      to: to,
    );

    // Void reason counts.
    final voidReasonKey = _voidReasonKeyExpr();
    final voidReasonCount = countAll();
    final voidReasonRows =
        await (_baseSalesAggregateQuery(from: from, to: to)
              ..addColumns([voidReasonKey, voidReasonCount])
              ..where(_voidedExpr)
              ..groupBy([voidReasonKey]))
            .get();
    final voidReasons = <String, int>{};
    for (final row in voidReasonRows) {
      final key = row.read(voidReasonKey);
      final count = row.read(voidReasonCount) ?? 0;
      if (key != null) voidReasons[key] = count;
    }

    return ReportSummary(
      netRevenue: Money.fromSatang(headerRow.netSatang),
      voidedTotal: Money.fromSatang(headerRow.voidedSatang),
      salesCount: headerRow.salesCount,
      voidCount: headerRow.voidCount,
      vatAmount: Money.fromSatang(headerRow.vatSatang),
      discountAmount: Money.fromSatang(headerRow.discountSatang),
      serviceChargeAmount: Money.fromSatang(headerRow.serviceChargeSatang),
      promotionDiscountAmount: Money.fromSatang(
        headerRow.promotionDiscountSatang,
      ),
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
      promotionCount: headerRow.promotionCount,
    );
  }

  /// Reactive variant of [queryReportSummary]: emits once immediately, then
  /// re-aggregates whenever `sales` or `sale_payments` changes.
  Stream<ReportSummary> watchReportSummary({DateTime? from, DateTime? to}) =>
      _watchRecompute([_db.sales, _db.salePayments], () {
        return queryReportSummary(from: from, to: to);
      });

  /// Daily revenue zero-filled across every calendar day in the range —
  /// chart-ready and semantically identical to
  /// `ReportCalculatorService.dailyRevenueBetween`.
  ///
  /// Day bucketing uses SQLite `date(created_at / 1000, 'unixepoch',
  /// 'localtime')`: drift persists DateTimes as unix milliseconds and the
  /// `'localtime'` modifier applies the OS timezone, matching Dart's local
  /// `DateTime(y, m, d)` components exactly (the POS timezone, Asia/Bangkok,
  /// has no DST).
  Future<List<DailyRevenue>> queryDailyRevenue({
    DateTime? from,
    DateTime? to,
  }) async {
    final dayKey = CustomExpression<String>(
      "date(${_createdAtSeconds()}, 'unixepoch', 'localtime')",
    );
    final revenueSum = _sumIf(_notVoidedExpr(), _completedTotalSumExpr());
    final completedCount = countAll(filter: _notVoidedExpr());
    final query = _baseSalesAggregateQuery(from: from, to: to)
      ..addColumns([dayKey, revenueSum, completedCount])
      ..groupBy([dayKey]);
    final byDaySatang = <String, int>{};
    final countByDay = <String, int>{};
    for (final row in await query.get()) {
      final key = row.read(dayKey);
      if (key == null) continue;
      byDaySatang[key] = row.read(revenueSum) ?? 0;
      countByDay[key] = row.read(completedCount) ?? 0;
    }
    return _zeroFillDailyRevenue(byDaySatang, countByDay, from, to);
  }

  /// Reactive variant of [queryDailyRevenue].
  Stream<List<DailyRevenue>> watchDailyRevenue({
    DateTime? from,
    DateTime? to,
  }) => _watchRecompute([_db.sales], () {
    return queryDailyRevenue(from: from, to: to);
  });

  /// Revenue grouped by hour-of-day (0–23, sparse like the calculator).
  Future<Map<int, double>> queryHourlyRevenue({
    DateTime? from,
    DateTime? to,
  }) async {
    final hourKey = CustomExpression<String>(
      "strftime('%H', ${_createdAtSeconds()}, 'unixepoch', 'localtime')",
    );
    final revenueSum = _sumIf(_notVoidedExpr(), _completedTotalSumExpr());
    final query = _baseSalesAggregateQuery(from: from, to: to)
      ..addColumns([hourKey, revenueSum])
      ..groupBy([hourKey]);
    final byHourSatang = <int, int>{};
    for (final row in await query.get()) {
      final key = row.read(hourKey);
      if (key == null) continue;
      byHourSatang[int.parse(key)] = row.read(revenueSum) ?? 0;
    }
    return Map.unmodifiable({
      for (final e in byHourSatang.entries) e.key: e.value / 100.0,
    });
  }

  /// Reactive variant of [queryHourlyRevenue].
  Stream<Map<int, double>> watchHourlyRevenue({DateTime? from, DateTime? to}) =>
      _watchRecompute([_db.sales], () {
        return queryHourlyRevenue(from: from, to: to);
      });

  /// Top products ranked by qty (ties broken by revenue then product id),
  /// resolved from `sale_items` joined to completed sales; unit cost comes
  /// from a LEFT JOIN on `products` excluding soft-deleted rows — matching
  /// the product-lookup semantics of the Dart calculator.
  ///
  /// Display name is `MAX(product_name)` across that product's lines; the
  /// Dart path keeps the last-seen name instead. These diverge only when the
  /// same product was sold under different historical names.
  Future<List<TopProductStat>> queryTopProductStats({
    DateTime? from,
    DateTime? to,
    int limit = 5,
  }) async {
    final items = _db.saleItems;
    final iq = '${items.actualTableName}.';

    final productId = CustomExpression<String>('$iq${items.productId.name}');
    final displayName = CustomExpression<String>(
      'MAX($iq${items.productName.name})',
    );
    final qtySum = items.qty.sum();
    final revenueSum = CustomExpression<int>(
      'SUM(${_moneySatangSql('$iq${items.subtotalSatang.name}', '$iq${items.subtotal.name}')})',
    );
    final costSum = CustomExpression<int>(
      'SUM(CASE WHEN ${_unitCostSatangSql()} > 0 '
      'THEN ${_unitCostSatangSql()} * $iq${items.qty.name} ELSE NULL END)',
    );
    final query = _db.selectOnly(_db.saleItems)
      ..addColumns([productId, displayName, qtySum, revenueSum, costSum])
      ..join([
        innerJoin(_db.sales, _db.sales.id.equalsExp(items.saleId)),
        leftOuterJoin(
          _db.products,
          _db.products.id.equalsExp(items.productId) &
              _db.products.deletedAt.isNull(),
        ),
      ])
      ..where(items.deletedAt.isNull() & _salesRange(from: from, to: to))
      ..groupBy([productId])
      ..orderBy([
        OrderingTerm.desc(qtySum),
        OrderingTerm.desc(revenueSum),
        OrderingTerm.asc(productId),
      ])
      ..limit(limit);

    final stats = <TopProductStat>[];
    for (final row in await query.get()) {
      final name = row.read(displayName) ?? row.read(productId) ?? '?';
      final qty = row.read(qtySum) ?? 0;
      final revenue = (row.read(revenueSum) ?? 0) / 100.0;
      final costSatang = row.read(costSum);
      final cost = costSatang == null ? null : costSatang / 100.0;
      final profit = cost == null ? null : revenue - cost;
      final margin = (cost == null || revenue <= 0)
          ? null
          : ((profit ?? 0) / revenue) * 100;
      stats.add(
        TopProductStat(
          displayName: name,
          qty: qty,
          revenue: revenue,
          cost: cost,
          profit: profit,
          marginPercent: margin,
        ),
      );
    }
    return stats;
  }

  /// Reactive variant of [queryTopProductStats].
  Stream<List<TopProductStat>> watchTopProductStats({
    DateTime? from,
    DateTime? to,
    int limit = 5,
  }) => _watchRecompute([_db.sales, _db.saleItems, _db.products], () {
    return queryTopProductStats(from: from, to: to, limit: limit);
  });

  /// Completed-order counts grouped by customer id (null/empty ids skipped —
  /// same rule as `ReportCalculatorService.customerOrderCounts`).
  Future<Map<String, int>> queryCustomerOrderCounts({
    DateTime? from,
    DateTime? to,
  }) async {
    final customerId = CustomExpression<String>(_salesCol('customer_id'));
    final completedCount = countAll(filter: _notVoidedExpr());
    final query = _baseSalesAggregateQuery(from: from, to: to)
      ..addColumns([customerId, completedCount])
      ..where(
        _notVoidedExpr() &
            const CustomExpression<bool>(
              "customer_id IS NOT NULL AND customer_id != ''",
            ),
      )
      ..groupBy([customerId]);
    final counts = <String, int>{};
    for (final row in await query.get()) {
      final key = row.read(customerId);
      final count = row.read(completedCount) ?? 0;
      if (key != null && key.isNotEmpty) counts[key] = count;
    }
    return Map.unmodifiable(counts);
  }

  /// Reactive variant of [queryCustomerOrderCounts].
  Stream<Map<String, int>> watchCustomerOrderCounts({
    DateTime? from,
    DateTime? to,
  }) => _watchRecompute([_db.sales], () {
    return queryCustomerOrderCounts(from: from, to: to);
  });

  /// Line-level profit analytics via `sale_items LEFT JOIN products`.
  /// Mirrors `ReportCalculatorService.profitAnalytics`: line revenue counts
  /// every completed line; cost accumulates only where the product exists
  /// (non-deleted) with positive unit cost.
  Future<ProfitAnalytics?> queryProfitAnalytics({
    DateTime? from,
    DateTime? to,
  }) async {
    final items = _db.saleItems;
    final iq = '${items.actualTableName}.';

    final lineRevenue = CustomExpression<int>(
      'SUM(${_moneySatangSql('$iq${items.subtotalSatang.name}', '$iq${items.subtotal.name}')})',
    );
    final lineCost = CustomExpression<int>(
      'SUM(CASE WHEN ${_unitCostSatangSql()} > 0 '
      'THEN ${_unitCostSatangSql()} * $iq${items.qty.name} ELSE NULL END)',
    );
    final withCostCount = countAll(
      filter: CustomExpression<bool>('${_unitCostSatangSql()} > 0'),
    );
    final totalLines = countAll();
    final query = _db.selectOnly(_db.saleItems)
      ..addColumns([lineRevenue, lineCost, withCostCount, totalLines])
      ..join([
        innerJoin(_db.sales, _db.sales.id.equalsExp(items.saleId)),
        leftOuterJoin(
          _db.products,
          _db.products.id.equalsExp(items.productId) &
              _db.products.deletedAt.isNull(),
        ),
      ])
      ..where(items.deletedAt.isNull() & _salesRange(from: from, to: to));
    final row = await query.getSingle();
    final revenueSatang = row.read(lineRevenue) ?? 0;
    final costSatang = row.read(lineCost) ?? 0;
    final withCount = row.read(withCostCount) ?? 0;
    final total = row.read(totalLines) ?? 0;

    final totalCost = Money.fromSatang(costSatang);
    final lineRevenueMoney = Money.fromSatang(revenueSatang);
    // Money's `-` operator clamps at zero — keep that behaviour here.
    final grossProfit = lineRevenueMoney - totalCost;
    final margin = revenueSatang <= 0
        ? 0.0
        : (grossProfit.satang * 100.0) / lineRevenueMoney.satang;
    return ProfitAnalytics(
      totalCost: totalCost,
      grossProfit: grossProfit,
      marginPercent: margin,
      itemsWithCost: withCount,
      itemsWithoutCost: total - withCount,
    );
  }

  /// Reactive variant of [queryProfitAnalytics].
  Stream<ProfitAnalytics?> watchProfitAnalytics({
    DateTime? from,
    DateTime? to,
  }) => _watchRecompute([_db.sales, _db.saleItems, _db.products], () {
    return queryProfitAnalytics(from: from, to: to);
  });

  /// PromptPay totals: sum/count over promptpay **tender legs**, plus legacy
  /// header-only promptpay bills (same leg-vs-header rule as
  /// `ReportCalculatorService.promptPayLegTotal`).
  Future<(int legTotalSatang, int billCount)> queryPromptPayStats({
    DateTime? from,
    DateTime? to,
  }) async {
    final legMethodKey = _normalizedMethodExpr(_payCol('method'));
    final legSum = CustomExpression<int>(
      'SUM(${_moneySatangSql(_payCol('amount_satang'), _payCol('amount'))})',
    );
    final legCount = countAll();
    final legQuery = _db.selectOnly(_db.sales)
      ..addColumns([legSum, legCount])
      ..join([
        innerJoin(
          _db.salePayments,
          _db.salePayments.saleId.equalsExp(_db.sales.id),
        ),
      ])
      ..where(
        _db.salePayments.deletedAt.isNull() &
            _salesRange(from: from, to: to) &
            _notVoidedExpr() &
            legMethodKey.equals('promptpay'),
      );
    final legRow = await legQuery.getSingle();

    final headerMethodKey = _normalizedMethodExpr(_salesCol('payment_method'));
    final headerTotalSum = CustomExpression<int>(
      'SUM(${_moneySatangSql(_salesCol('total_amount_satang'), _salesCol('total_amount'))})',
    );
    final headerCount = countAll();
    final headerQuery = _db.selectOnly(_db.sales)
      ..addColumns([headerTotalSum, headerCount])
      ..join([
        leftOuterJoin(
          _db.salePayments,
          _db.salePayments.saleId.equalsExp(_db.sales.id) &
              _db.salePayments.deletedAt.isNull(),
        ),
      ])
      ..where(
        _db.salePayments.id.isNull() &
            _salesRange(from: from, to: to) &
            _notVoidedExpr() &
            headerMethodKey.equals('promptpay'),
      );
    final headerRow = await headerQuery.getSingle();

    final int legTotalSatang =
        (legRow.read(legSum) ?? 0) + (headerRow.read(headerTotalSum) ?? 0);
    final int billCount =
        (legRow.read(legCount) ?? 0) + (headerRow.read(headerCount) ?? 0);
    return (legTotalSatang, billCount);
  }

  /// Bounded hydration of the newest PromptPay bills in range (display list
  /// only — metrics come from [queryPromptPayStats]).
  Future<List<Sale>> queryRecentPromptPaySales({
    DateTime? from,
    DateTime? to,
    int limit = kRecentPromptPayBillLimit,
  }) async {
    final sales = _db.sales;
    final payments = _db.salePayments;
    final payQualified = '${payments.actualTableName}.';

    final hasPromptPayLeg = existsQuery(
      _db.select(payments)
        ..addColumns([payments.id])
        ..where(
          (p) =>
              p.saleId.equalsExp(sales.id) &
              p.deletedAt.isNull() &
              _normalizedMethodExpr(
                '$payQualified${payments.method.name}',
              ).equals('promptpay'),
        ),
    );
    final hasAnyLeg = existsQuery(
      _db.select(payments)
        ..addColumns([payments.id])
        ..where((p) => p.saleId.equalsExp(sales.id) & p.deletedAt.isNull()),
    );
    final headerIsPromptPay = _normalizedMethodExpr(
      '${sales.actualTableName}.${sales.paymentMethod.name}',
    ).equals('promptpay');

    var query = _db.select(sales)..where((s) => s.deletedAt.isNull());
    if (from != null) {
      query.where((s) => s.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where((s) => s.createdAt.isSmallerOrEqualValue(to));
    }
    query.where(
      (s) =>
          (hasPromptPayLeg | (hasAnyLeg.not() & headerIsPromptPay)) &
          s.status.equals('VOIDED').not(),
    );
    query
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit);
    final rows = await query.get();
    return hydrateSales(rows);
  }

  /// Everything the long-range ReportCubit path needs for one period,
  /// aggregated in SQL. See [watchReportAggregate] for reactivity.
  Future<ReportAggregate> queryReportAggregate({
    DateTime? from,
    DateTime? to,
  }) async {
    final summary = await queryReportSummary(from: from, to: to);
    final daily = await queryDailyRevenue(from: from, to: to);
    final hourly = await queryHourlyRevenue(from: from, to: to);
    final topProducts = await queryTopProductStats(from: from, to: to);
    final customers = await queryCustomerOrderCounts(from: from, to: to);
    final profit = await queryProfitAnalytics(from: from, to: to);
    final (ppTotalSatang, ppBillCount) = await queryPromptPayStats(
      from: from,
      to: to,
    );
    final recentPpBills = await queryRecentPromptPaySales(from: from, to: to);
    return ReportAggregate(
      summary: summary,
      dailyRevenue: daily,
      hourlyRevenue: hourly,
      topProducts: topProducts,
      uniqueCustomers: customers.length,
      repeatCustomers: customers.values.where((c) => c > 1).length,
      profit: profit,
      promptPayLegTotal: Money.fromSatang(ppTotalSatang),
      promptPayBillCount: ppBillCount,
      recentPromptPaySales: recentPpBills,
    );
  }

  /// Reactive variant of [queryReportAggregate]: emits immediately, then
  /// recomputes whenever any contributing table changes.
  Stream<ReportAggregate> watchReportAggregate({
    DateTime? from,
    DateTime? to,
  }) => _watchRecompute([
    _db.sales,
    _db.salePayments,
    _db.saleItems,
    _db.products,
  ], () => queryReportAggregate(from: from, to: to));

  /// Reference implementation retained deliberately for equivalence testing:
  /// hydrates every sale in range and sums in Dart exactly like the pre-SQL
  /// path. Do NOT use in production code — [queryReportSummary] replaces it.
  @visibleForTesting
  Future<ReportSummary> dartReportSummaryReference({
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

    final paymentBreakdownSatang = <String, int>{};
    final paymentCounts = <String, int>{};
    final saleIds = salesRows.map((s) => s.id).toSet();
    if (saleIds.isNotEmpty) {
      // Chunk the payment lookup to stay under SQLite's variable limit.
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

  // ---------------------------------------------------------------------------
  // Aggregate query/expression builders.
  //
  // Expressions are created once per query and reused between addColumns and
  // read() — drift matches result columns by expression identity.
  // ---------------------------------------------------------------------------

  String _salesCol(String columnName) =>
      '${_db.sales.actualTableName}.$columnName';

  String _payCol(String columnName) =>
      '${_db.salePayments.actualTableName}.$columnName';

  /// `created_at` expressed in unix seconds (drift stores milliseconds).
  String _createdAtSeconds() => '${_salesCol("created_at")} / 1000';

  /// Satang reader SQL: prefer the dual-written satang column; legacy rows
  /// fall back to ROUND(baht * 100) half-away-from-zero — identical to
  /// [moneyFromSatangOrBaht] because both engines compute the product in
  /// IEEE-754 doubles before rounding.
  String _moneySatangSql(String satangColumn, String bahtColumn) =>
      'COALESCE($satangColumn, CAST(ROUND($bahtColumn * 100) AS INTEGER))';

  /// Unit-cost reader for the LEFT-JOINed product alias (NULL when absent).
  String _unitCostSatangSql() => _moneySatangSql(
    '${_db.products.actualTableName}.cost_satang',
    '${_db.products.actualTableName}.cost',
  );

  Expression<bool> _notVoidedExpr() =>
      const CustomExpression<bool>("status != 'VOIDED'");

  Expression<bool> get _voidedExpr =>
      const CustomExpression<bool>("status = 'VOIDED'");

  Expression<int> _completedTotalSumExpr() => CustomExpression<int>(
    _moneySatangSql(
      _salesCol('total_amount_satang'),
      _salesCol('total_amount'),
    ),
  );

  Expression<String> _voidReasonKeyExpr() => CustomExpression<String>(
    "COALESCE(NULLIF(TRIM(${_salesCol('void_reason')}), ''), 'unspecified')",
  );

  Expression<int> _sumIf(Expression<bool> condition, Expression<int> value) =>
      CaseWhenExpression<int>(cases: [CaseWhen(condition, then: value)]).sum();

  /// SQL replica of [normalizePaymentMethod] (case-sensitive equality,
  /// unknown values pass through unchanged).
  Expression<String> _normalizedMethodExpr(String qualifiedMethodColumn) {
    final mapping = const <String, String>{
      'เงินสด': 'cash',
      'cash': 'cash',
      'โอน': 'transfer',
      'transfer': 'transfer',
      'บัตร': 'card',
      'card': 'card',
      'promptpay': 'promptpay',
      'mixed': 'mixed',
    };
    return CaseWhenExpression<String>(
      cases: [
        for (final entry in mapping.entries)
          CaseWhen(
            CustomExpression<bool>(
              "$qualifiedMethodColumn = '${entry.key.replaceAll("'", "''")}'",
            ),
            then: Constant(entry.value),
          ),
      ],
      orElse: CustomExpression<String>(qualifiedMethodColumn),
    );
  }

  /// Deleted-aware createdAt window over `sales`. Built from real column
  /// expressions so drift qualifies table names automatically once a query
  /// joins more than one table.
  Expression<bool> _salesRange({DateTime? from, DateTime? to}) {
    var range = _db.sales.deletedAt.isNull();
    if (from != null) {
      range = range & _db.sales.createdAt.isBiggerOrEqualValue(from);
    }
    if (to != null) {
      range = range & _db.sales.createdAt.isSmallerOrEqualValue(to);
    }
    return range;
  }

  JoinedSelectStatement _baseSalesAggregateQuery({
    DateTime? from,
    DateTime? to,
  }) {
    final query = _db.selectOnly(_db.sales)
      ..where(_db.sales.deletedAt.isNull());
    if (from != null) {
      query.where(_db.sales.createdAt.isBiggerOrEqualValue(from));
    }
    if (to != null) {
      query.where(_db.sales.createdAt.isSmallerOrEqualValue(to));
    }
    return query;
  }

  /// Single pass over `sales` producing every header aggregate. Expressions
  /// are created here and read directly — never rebuilt — so drift's
  /// expression-identity result mapping stays correct.
  Future<_SummaryHeader> _readSummaryHeader({
    DateTime? from,
    DateTime? to,
  }) async {
    final totalSatang = CustomExpression<int>(
      _moneySatangSql(
        _salesCol('total_amount_satang'),
        _salesCol('total_amount'),
      ),
    );
    final vatSatang = CustomExpression<int>(
      _moneySatangSql(_salesCol('vat_amount_satang'), _salesCol('vat_amount')),
    );
    final discountSatang = CustomExpression<int>(
      _moneySatangSql(
        _salesCol('discount_amount_satang'),
        _salesCol('discount_amount'),
      ),
    );
    final scSatang = CustomExpression<int>(
      _moneySatangSql(
        _salesCol('service_charge_amount_satang'),
        _salesCol('service_charge_amount'),
      ),
    );
    final promoSatang = CustomExpression<int>(
      _moneySatangSql(
        _salesCol('promotion_discount_amount_satang'),
        _salesCol('promotion_discount_amount'),
      ),
    );
    final notVoided = _notVoidedExpr();
    final promoted = const CustomExpression<bool>(
      '(promotion_id IS NOT NULL OR promotion_discount_amount > 0)',
    );

    final netSum = _sumIf(notVoided, totalSatang);
    final voidedSum = _sumIf(_voidedExpr, totalSatang);
    final vatSum = _sumIf(notVoided, vatSatang);
    final discountSum = _sumIf(notVoided, discountSatang);
    final scSum = _sumIf(notVoided, scSatang);
    final promoSum = _sumIf(notVoided, promoSatang);
    final salesCountExpr = countAll(filter: notVoided);
    final voidCountExpr = countAll(filter: _voidedExpr);
    final promotionCountExpr = _sumIf(notVoided & promoted, const Constant(1));

    final row =
        await (_db.selectOnly(_db.sales)
              ..addColumns([
                netSum,
                voidedSum,
                vatSum,
                discountSum,
                scSum,
                promoSum,
                salesCountExpr,
                voidCountExpr,
                promotionCountExpr,
              ])
              ..where(_salesRange(from: from, to: to)))
            .getSingle();

    return _SummaryHeader(
      netSatang: row.read(netSum) ?? 0,
      voidedSatang: row.read(voidedSum) ?? 0,
      vatSatang: row.read(vatSum) ?? 0,
      discountSatang: row.read(discountSum) ?? 0,
      serviceChargeSatang: row.read(scSum) ?? 0,
      promotionDiscountSatang: row.read(promoSum) ?? 0,
      salesCount: row.read(salesCountExpr) ?? 0,
      voidCount: row.read(voidCountExpr) ?? 0,
      promotionCount: row.read(promotionCountExpr) ?? 0,
    );
  }

  /// Total revenue grouped by an arbitrary sales column (completed only).
  Future<Map<String, int>> _sumTotalsGrouped({
    required String groupColumnSql,
    DateTime? from,
    DateTime? to,
  }) async {
    final groupKey = CustomExpression<String>(groupColumnSql);
    final totalSum = CustomExpression<int>(
      'SUM(${_moneySatangSql(_salesCol('total_amount_satang'), _salesCol('total_amount'))})',
    );
    final query = _baseSalesAggregateQuery(from: from, to: to)
      ..addColumns([groupKey, totalSum])
      ..where(_notVoidedExpr())
      ..groupBy([groupKey]);
    final result = <String, int>{};
    for (final row in await query.get()) {
      final key = row.read(groupKey);
      if (key != null) result[key] = row.read(totalSum) ?? 0;
    }
    return result;
  }

  /// Maps grouped day keys onto zero-filled [DailyRevenue] entries covering
  /// every calendar day between [from] and [to] (swapped when reversed;
  /// unbounded when either bound is null).
  List<DailyRevenue> _zeroFillDailyRevenue(
    Map<String, int> byDaySatang,
    Map<String, int> countByDay,
    DateTime? from,
    DateTime? to,
  ) {
    if (from == null || to == null) {
      final keys = byDaySatang.keys.toList()..sort();
      return [
        for (final key in keys)
          DailyRevenue(
            date: _parseDayKey(key),
            revenue: byDaySatang[key]! / 100.0,
            count: countByDay[key] ?? 0,
          ),
      ];
    }
    var first = DateTime(from.year, from.month, from.day);
    var last = DateTime(to.year, to.month, to.day);
    if (last.isBefore(first)) {
      final tmp = first;
      first = last;
      last = tmp;
    }
    final result = <DailyRevenue>[];
    for (
      var day = first;
      !day.isAfter(last);
      day = day.add(const Duration(days: 1))
    ) {
      final key = _dayKey(day);
      result.add(
        DailyRevenue(
          date: day,
          revenue: (byDaySatang[key] ?? 0) / 100.0,
          count: countByDay[key] ?? 0,
        ),
      );
    }
    return result;
  }

  DateTime _parseDayKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  String _dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  /// Emits once immediately, then re-runs [compute] whenever any of [tables]
  /// changes. Drift table-update streams carry no payload, so each event
  /// triggers one bounded aggregation query — never a full hydration.
  Stream<T> _watchRecompute<T>(
    Iterable<ResultSetImplementation> tables,
    Future<T> Function() compute,
  ) async* {
    yield await compute();
    await for (final _ in _db.tableUpdates(
      TableUpdateQuery.onAllTables(tables),
    )) {
      yield await compute();
    }
  }

  // ---------------------------------------------------------------------------
  // Row → domain hydration (bounded paths).
  // ---------------------------------------------------------------------------

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

/// Header aggregates for one period, read from a single pass over `sales`.
class _SummaryHeader {
  const _SummaryHeader({
    required this.netSatang,
    required this.voidedSatang,
    required this.salesCount,
    required this.voidCount,
    required this.vatSatang,
    required this.discountSatang,
    required this.serviceChargeSatang,
    required this.promotionDiscountSatang,
    required this.promotionCount,
  });

  final int netSatang;
  final int voidedSatang;
  final int salesCount;
  final int voidCount;
  final int vatSatang;
  final int discountSatang;
  final int serviceChargeSatang;
  final int promotionDiscountSatang;
  final int promotionCount;
}
