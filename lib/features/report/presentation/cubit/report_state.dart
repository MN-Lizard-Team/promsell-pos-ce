import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

const Object _unset = Object();

enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  const ReportState({
    this.status = ReportStatus.initial,
    this.sales = const [],
    this.previousSales = const [],
    this.dailyRevenue = const [],
    this.profit,
    this.previousProfit,
    this.productLookup = const {},
    this.from,
    this.to,
    this.lastUpdated,
  });

  final ReportStatus status;
  final List<Sale> sales;
  final List<Sale> previousSales;
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

  bool get isEmpty => status == ReportStatus.success && sales.isEmpty;

  ReportState copyWith({
    ReportStatus? status,
    List<Sale>? sales,
    List<Sale>? previousSales,
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
    dailyRevenue,
    profit,
    previousProfit,
    productLookup,
    from,
    to,
    lastUpdated,
  ];
}
