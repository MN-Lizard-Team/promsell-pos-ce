import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

const Object _unset = Object();

enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  const ReportState({
    this.status = ReportStatus.initial,
    this.sales = const [],
    this.previousSales = const [],
    this.aggregate,
    this.previousSummary,
    this.dailyRevenue = const [],
    this.profit,
    this.previousProfit,
    this.productLookup = const {},
    this.from,
    this.to,
    this.lastUpdated,
  });

  final ReportStatus status;

  /// Hydrated sales for ranges within [ReportCubit.maxHydratedSpanDays].
  /// Empty when the active range is served by the SQL-aggregate path
  /// ([aggregate] is non-null) or before the first load completes.
  final List<Sale> sales;
  final List<Sale> previousSales;

  /// SQL-aggregated bundle used for ranges longer than
  /// [ReportCubit.maxHydratedSpanDays]. Null on the hydrated path.
  final ReportAggregate? aggregate;

  /// Previous-period summary (SQL) powering the net-revenue comparison on
  /// long ranges. Null on the hydrated path (previous period uses
  /// [previousSales]).
  final ReportSummary? previousSummary;

  final List<DailyRevenue> dailyRevenue;
  final ProfitAnalytics? profit;
  final ProfitAnalytics? previousProfit;

  /// Cached productId → Product map for per-product cost/profit calculations.
  final Map<String, Product> productLookup;
  final DateTime? from;
  final DateTime? to;

  /// Wall-clock time of the most recent successful data load.
  final DateTime? lastUpdated;

  bool get isLoading => status == ReportStatus.loading;
  bool get hasError => status == ReportStatus.failure;

  /// True when the active range has no sales at all, regardless of which
  /// data path (hydrated vs aggregated) produced the state.
  bool get isEmpty {
    if (status != ReportStatus.success) return false;
    if (aggregate != null) {
      return aggregate!.summary.salesCount == 0 &&
          aggregate!.summary.voidCount == 0;
    }
    return sales.isEmpty;
  }

  ReportState copyWith({
    ReportStatus? status,
    List<Sale>? sales,
    List<Sale>? previousSales,
    Object? aggregate = _unset,
    Object? previousSummary = _unset,
    List<DailyRevenue>? dailyRevenue,
    Object? profit = _unset,
    Object? previousProfit = _unset,
    Map<String, Product>? productLookup,
    Object? from = _unset,
    Object? to = _unset,
    Object? lastUpdated = _unset,
  }) {
    return ReportState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      previousSales: previousSales ?? this.previousSales,
      aggregate: identical(aggregate, _unset)
          ? this.aggregate
          : aggregate as ReportAggregate?,
      previousSummary: identical(previousSummary, _unset)
          ? this.previousSummary
          : previousSummary as ReportSummary?,
      dailyRevenue: dailyRevenue ?? this.dailyRevenue,
      profit: identical(profit, _unset)
          ? this.profit
          : profit as ProfitAnalytics?,
      previousProfit: identical(previousProfit, _unset)
          ? this.previousProfit
          : previousProfit as ProfitAnalytics?,
      productLookup: productLookup ?? this.productLookup,
      from: identical(from, _unset) ? this.from : from as DateTime?,
      to: identical(to, _unset) ? this.to : to as DateTime?,
      lastUpdated: identical(lastUpdated, _unset)
          ? this.lastUpdated
          : lastUpdated as DateTime?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sales,
    previousSales,
    aggregate,
    previousSummary,
    dailyRevenue,
    profit,
    previousProfit,
    productLookup,
    from,
    to,
    lastUpdated,
  ];
}
