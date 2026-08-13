import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';

/// Aggregated report data for a given period.
///
/// This is the single source of truth for the Report page UI.
/// Computed once from a [List<Sale>] and then passed to widgets.
@immutable
class ReportData extends Equatable {
  const ReportData({
    required this.sales,
    required this.from,
    required this.to,
    required this.totals,
    this.dailyRevenue = const [],
    this.previousPeriod,
    this.profit,
  });

  /// All sales in the period (completed + voided).
  final List<Sale> sales;

  /// Start of the reporting period (inclusive, start-of-day).
  final DateTime from;

  /// End of the reporting period (inclusive, end-of-day).
  final DateTime to;

  /// Pre-computed period totals (net revenue, void counts, etc.).
  final SalesPeriodTotals totals;

  /// Daily revenue breakdown for charting.
  final List<DailyRevenue> dailyRevenue;

  /// Previous period data for comparison (same length, immediately before [from]).
  final ReportData? previousPeriod;

  /// Profit/margin analytics derived from product cost data.
  /// Null when product cost lookup is unavailable.
  final ProfitAnalytics? profit;

  /// Number of days in the period.
  int get daysSpan => to.difference(from).inDays + 1;

  @override
  List<Object?> get props => [
    sales,
    from,
    to,
    totals,
    dailyRevenue,
    previousPeriod,
    profit,
  ];
}

/// Profit and margin analytics for a report period.
///
/// Computed by matching [SaleItem.productId] against a product lookup map
/// (productId → Product) and summing `product.cost * qty` for completed sales.
/// Items whose product cannot be found or whose cost is zero are counted as
/// "uncovered" so the UI can warn the user about incomplete cost data.
@immutable
class ProfitAnalytics extends Equatable {
  const ProfitAnalytics({
    required this.totalCost,
    required this.grossProfit,
    required this.marginPercent,
    required this.itemsWithCost,
    required this.itemsWithoutCost,
  });

  /// Sum of (product.cost * qty) for completed sale items with cost data.
  final Money totalCost;

  /// Net revenue minus [totalCost]. Uses line subtotals as the revenue base
  /// so discounts on the cart header do not distort per-item margin.
  final Money grossProfit;

  /// [grossProfit] / line revenue * 100. 0 when there is no revenue.
  final double marginPercent;

  /// Number of sale line items that had a matching product cost.
  final int itemsWithCost;

  /// Number of sale line items without a matching product cost (lookup miss
  /// or zero cost). A high value means [marginPercent] is unreliable.
  final int itemsWithoutCost;

  /// Total line items considered.
  int get totalItems => itemsWithCost + itemsWithoutCost;

  /// Fraction of line items with cost data (0..1). 1.0 means full coverage.
  double get coveragePercent =>
      totalItems == 0 ? 0 : itemsWithCost / totalItems;

  /// True when every line item has cost data.
  bool get hasFullCoverage => itemsWithoutCost == 0;

  /// True when no cost data is available at all.
  bool get hasNoCoverage => itemsWithCost == 0;

  static const empty = ProfitAnalytics(
    totalCost: Money.zero,
    grossProfit: Money.zero,
    marginPercent: 0,
    itemsWithCost: 0,
    itemsWithoutCost: 0,
  );

  @override
  List<Object?> get props => [
    totalCost,
    grossProfit,
    marginPercent,
    itemsWithCost,
    itemsWithoutCost,
  ];
}

/// Revenue for a single calendar day.
@immutable
class DailyRevenue extends Equatable {
  const DailyRevenue({
    required this.date,
    required this.revenue,
    required this.count,
  });

  final DateTime date;
  final double revenue;
  final int count;

  @override
  List<Object?> get props => [date, revenue, count];
}
