import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/top_product_stat.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sales_period_totals.dart';

/// Fully SQL-aggregated report bundle for one period.
///
/// Produced by [ReportAggregateDataSource]-style datasource queries without
/// hydrating `List<Sale>` — every metric below comes from `SUM`/`GROUP BY`
/// over the satang columns (with legacy REAL-baht fallbacks). Used by
/// ReportCubit's long-range (>31 days) path so memory stays bounded
/// regardless of how many sales fall inside the window.
@immutable
class ReportAggregate extends Equatable {
  const ReportAggregate({
    required this.summary,
    this.dailyRevenue = const [],
    this.hourlyRevenue = const {},
    this.topProducts = const [],
    this.uniqueCustomers = 0,
    this.repeatCustomers = 0,
    this.profit,
    this.promptPayLegTotal = Money.zero,
    this.promptPayBillCount = 0,
    this.recentPromptPaySales = const [],
  });

  /// Header totals, breakdowns, and counts derived from the `sales` +
  /// `sale_payments` tables.
  final ReportSummary summary;

  /// Daily revenue zero-filled across the requested range (chart-ready).
  final List<DailyRevenue> dailyRevenue;

  /// Revenue grouped by hour-of-day (sparse — hours without sales omitted).
  final Map<int, double> hourlyRevenue;

  /// Top products ranked by qty (then revenue), limited at the SQL level.
  final List<TopProductStat> topProducts;

  /// Distinct customer ids across completed sales.
  final int uniqueCustomers;

  /// Customers with more than one completed order.
  final int repeatCustomers;

  /// Line-level cost/profit analytics (sale_items LEFT JOIN products).
  /// Null when cost coverage could not be computed.
  final ProfitAnalytics? profit;

  /// Sum of PromptPay tender legs (legacy header-only bills included).
  final Money promptPayLegTotal;

  /// Number of PromptPay bills behind [promptPayLegTotal].
  final int promptPayBillCount;

  /// Bounded hydration (default 5 newest) of PromptPay bills for display.
  final List<Sale> recentPromptPaySales;

  /// Same-period totals shaped for the existing report cards.
  SalesPeriodTotals get totals => SalesPeriodTotals(
    netRevenue: summary.netRevenue,
    voidedTotal: summary.voidedTotal,
    salesCount: summary.salesCount,
    voidCount: summary.voidCount,
    vatAmount: summary.vatAmount,
    discountAmount: summary.discountAmount,
    serviceChargeAmount: summary.serviceChargeAmount,
    promotionDiscountAmount: summary.promotionDiscountAmount,
    paymentBreakdown: summary.paymentBreakdown,
    paymentCounts: summary.paymentCounts,
    orderTypeBreakdown: summary.orderTypeBreakdown,
    orderChannelBreakdown: summary.orderChannelBreakdown,
    voidReasonBreakdown: summary.voidReasonBreakdown,
    promotionCount: summary.promotionCount,
  );

  @override
  List<Object?> get props => [
    summary,
    dailyRevenue,
    hourlyRevenue,
    topProducts,
    uniqueCustomers,
    repeatCustomers,
    profit,
    promptPayLegTotal,
    promptPayBillCount,
    recentPromptPaySales,
  ];
}
