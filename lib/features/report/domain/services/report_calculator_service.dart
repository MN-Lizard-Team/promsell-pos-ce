import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/top_product_stat.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';

/// Single source of truth for all report metric calculations.
///
/// Migrated from `ReportCalculator` extension on `List<Sale>` so the
/// Report feature owns a testable, injectable domain service instead of
/// relying on extension methods scattered across presentation call sites.
@injectable
class ReportCalculatorService {
  const ReportCalculatorService();

  // Filter helpers
  List<Sale> completedSales(List<Sale> sales) =>
      sales.where((s) => !s.isVoided).toList();

  List<Sale> voidedSales(List<Sale> sales) =>
      sales.where((s) => s.isVoided).toList();

  // Period totals
  /// Single source of truth for period money metrics (shared with Daily Close).
  SalesPeriodTotals periodTotals(List<Sale> sales) =>
      SalesPeriodTotals.from(sales);

  Money netRevenue(List<Sale> sales) => periodTotals(sales).netRevenue;

  Money voidedTotal(List<Sale> sales) => periodTotals(sales).voidedTotal;

  Map<String, double> byPaymentMethod(List<Sale> sales) =>
      periodTotals(sales).paymentBreakdown;

  Map<String, int> paymentMethodCounts(List<Sale> sales) =>
      periodTotals(sales).paymentCounts;

  // Daily revenue
  /// Computes daily revenue breakdown for charting (sparse — no zero-fill).
  List<DailyRevenue> dailyRevenue(List<Sale> sales) {
    final completed = completedSales(sales);
    final byDaySatang = <DateTime, int>{};
    final countByDay = <DateTime, int>{};
    for (final s in completed) {
      final key = DateTime(
        s.createdAt.year,
        s.createdAt.month,
        s.createdAt.day,
      );
      byDaySatang[key] = (byDaySatang[key] ?? 0) + s.totalAmount.satang;
      countByDay[key] = (countByDay[key] ?? 0) + 1;
    }
    final sortedKeys = byDaySatang.keys.toList()..sort();
    return sortedKeys
        .map(
          (d) => DailyRevenue(
            date: d,
            revenue: byDaySatang[d]! / 100.0,
            count: countByDay[d]!,
          ),
        )
        .toList();
  }

  /// Computes daily revenue for every calendar day in [from]..[to].
  ///
  /// Days without completed sales are retained with zero revenue so charts do
  /// not imply continuity between non-consecutive sales days.
  List<DailyRevenue> dailyRevenueBetween(
    List<Sale> sales,
    DateTime from,
    DateTime to,
  ) {
    final completed = completedSales(sales);

    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    final first = end.isBefore(start) ? end : start;
    final last = end.isBefore(start) ? start : end;
    final byDaySatang = <DateTime, int>{};
    final countByDay = <DateTime, int>{};

    for (final s in completed) {
      final day = DateTime(
        s.createdAt.year,
        s.createdAt.month,
        s.createdAt.day,
      );
      if (day.isBefore(first) || day.isAfter(last)) continue;
      byDaySatang[day] = (byDaySatang[day] ?? 0) + s.totalAmount.satang;
      countByDay[day] = (countByDay[day] ?? 0) + 1;
    }

    final result = <DailyRevenue>[];
    for (
      var day = first;
      !day.isAfter(last);
      day = day.add(const Duration(days: 1))
    ) {
      result.add(
        DailyRevenue(
          date: day,
          revenue: (byDaySatang[day] ?? 0) / 100.0,
          count: countByDay[day] ?? 0,
        ),
      );
    }
    return result;
  }

  // Top products
  /// Top products ranked by **qty**; [TopProductStat.revenue] is
  /// sum of [SaleItem.subtotal] for completed sales only.
  ///
  /// When [productLookup] is provided, per-product [TopProductStat.cost],
  /// [TopProductStat.profit], and [TopProductStat.marginPercent] are also
  /// populated from `Product.cost`.
  List<TopProductStat> topProductStats(
    List<Sale> sales, {
    int limit = 5,
    Map<String, Product>? productLookup,
  }) {
    final completed = completedSales(sales);
    final qtyById = <String, int>{};
    final revByIdSatang = <String, int>{};
    final costByIdSatang = <String, int>{};
    final nameById = <String, String>{};
    for (final s in completed) {
      for (final item in s.items) {
        nameById[item.productId] = item.productName;
        qtyById[item.productId] = (qtyById[item.productId] ?? 0) + item.qty;
        revByIdSatang[item.productId] =
            (revByIdSatang[item.productId] ?? 0) + item.subtotal.satang;
        if (productLookup != null) {
          final unitCostSatang =
              productLookup[item.productId]?.cost.satang ?? 0;
          if (unitCostSatang > 0) {
            costByIdSatang[item.productId] =
                (costByIdSatang[item.productId] ?? 0) +
                unitCostSatang * item.qty;
          }
        }
      }
    }
    final sorted = qtyById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = sorted.take(limit).toList();
    final nameCounts = <String, int>{};
    for (final e in topEntries) {
      final name = nameById[e.key] ?? e.key;
      nameCounts[name] = (nameCounts[name] ?? 0) + 1;
    }
    return topEntries.map((e) {
      final name = nameById[e.key] ?? e.key;
      final disambiguate = (nameCounts[name] ?? 0) > 1;
      final display = disambiguate
          ? '$name (${e.key.substring(0, e.key.length.clamp(0, 4))})'
          : name;
      final revenue = (revByIdSatang[e.key] ?? 0) / 100.0;
      final costSatang = costByIdSatang[e.key];
      final cost = costSatang == null ? null : costSatang / 100.0;
      final profit = cost != null ? revenue - cost : null;
      final margin = (cost != null && revenue > 0)
          ? (profit! / revenue) * 100
          : null;
      return TopProductStat(
        displayName: display,
        qty: e.value,
        revenue: revenue,
        cost: cost,
        profit: profit,
        marginPercent: margin,
      );
    }).toList();
  }

  /// Compatibility map name → qty (rank still by qty via [topProductStats]).
  Map<String, int> topProducts(List<Sale> sales) => {
    for (final s in topProductStats(sales)) s.displayName: s.qty,
  };

  // Customer metrics
  /// Number of completed orders grouped by customer id.
  Map<String, int> customerOrderCounts(List<Sale> sales) {
    final completed = completedSales(sales);
    final counts = <String, int>{};
    for (final sale in completed) {
      final id = sale.customerId;
      if (id == null || id.isEmpty) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return Map.unmodifiable(counts);
  }

  int uniqueCustomerCount(List<Sale> sales) =>
      customerOrderCounts(sales).length;

  int repeatCustomerCount(List<Sale> sales) =>
      customerOrderCounts(sales).values.where((count) => count > 1).length;

  // Hourly revenue
  /// Revenue grouped by hour of day for completed sales.
  Map<int, double> hourlyRevenue(List<Sale> sales) {
    final completed = completedSales(sales);
    final byHourSatang = <int, int>{};
    for (final sale in completed) {
      byHourSatang[sale.createdAt.hour] =
          (byHourSatang[sale.createdAt.hour] ?? 0) + sale.totalAmount.satang;
    }
    return Map.unmodifiable({
      for (final entry in byHourSatang.entries) entry.key: entry.value / 100.0,
    });
  }

  // Profit analytics
  /// Computes [ProfitAnalytics] for completed sales using [productLookup]
  /// (productId → Product). Items whose product is missing or has zero cost
  /// are counted as uncovered so the UI can flag unreliable margins.
  ProfitAnalytics profitAnalytics(
    List<Sale> sales,
    Map<String, Product> productLookup,
  ) {
    final completed = completedSales(sales);
    var lineRevenueSatang = 0;
    var lineCostSatang = 0;
    var withCost = 0;
    var withoutCost = 0;

    for (final sale in completed) {
      for (final item in sale.items) {
        final product = productLookup[item.productId];
        final unitCostSatang = product?.cost.satang ?? 0;
        lineRevenueSatang += item.subtotal.satang;
        if (product == null || unitCostSatang <= 0) {
          withoutCost++;
          continue;
        }
        lineCostSatang += unitCostSatang * item.qty;
        withCost++;
      }
    }

    final totalCost = Money.fromSatang(lineCostSatang);
    final lineRevenueMoney = Money.fromSatang(lineRevenueSatang);
    final grossProfit = lineRevenueMoney - totalCost;
    final margin = lineRevenueSatang <= 0
        ? 0.0
        : (grossProfit.satang * 100.0) / lineRevenueMoney.satang;

    return ProfitAnalytics(
      totalCost: totalCost,
      grossProfit: grossProfit,
      marginPercent: margin,
      itemsWithCost: withCost,
      itemsWithoutCost: withoutCost,
    );
  }

  // PromptPay leg helpers (multi-tender safe)
  /// Non-void bills that include any PromptPay tender, newest first.
  List<Sale> promptPaySales(List<Sale> sales) {
    return sales.where((s) => !s.isVoided && saleIncludesPromptPay(s)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Sum of PromptPay **legs** (not full bill total on mixed sales).
  Money promptPayLegTotal(List<Sale> sales) {
    var sum = Money.zero;
    for (final s in promptPaySales(sales)) {
      sum += promptPayLegAmount(s);
    }
    return sum;
  }

  /// PromptPay leg total for one bill (not full mixed-tender total).
  Money promptPayLegAmount(Sale sale) {
    if (sale.payments.isNotEmpty) {
      var sum = Money.zero;
      for (final p in sale.payments) {
        if (normalizePaymentMethod(p.method) == 'promptpay') {
          sum += p.amount;
        }
      }
      return sum;
    }
    // Legacy header-only PromptPay bills.
    if (normalizePaymentMethod(sale.paymentMethod) == 'promptpay') {
      return sale.totalAmount;
    }
    return Money.zero;
  }
}
