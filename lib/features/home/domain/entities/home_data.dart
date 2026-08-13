import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

class HomeData extends Equatable {
  const HomeData({
    required this.todayRevenue,
    required this.trendData,
    required this.todaySales,
    required this.todaySalesCount,
    required this.todayCost,
    required this.costReady,
  });

  final Money todayRevenue;
  final List<double> trendData;
  final List<Sale> todaySales;
  final int todaySalesCount;
  final Money todayCost;

  /// False while product catalog is still loading — cost/profit must not show as 0.
  final bool costReady;

  @override
  List<Object?> get props => [
    todayRevenue,
    trendData,
    todaySales,
    todaySalesCount,
    todayCost,
    costReady,
  ];
}
