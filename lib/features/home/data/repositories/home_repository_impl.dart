import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/home/domain/entities/home_data.dart';
import 'package:promsell_pos_ce/features/home/domain/repositories/home_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sales_period_totals.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@LazySingleton(as: HomeRepository)
class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._saleRepo, this._productRepo);

  final SaleRepository _saleRepo;
  final ProductRepository _productRepo;

  @override
  Future<HomeData> loadHomeData() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.copyWith(
      hour: 23,
      minute: 59,
      second: 59,
      millisecond: 999,
    );
    final weekStart = todayStart.subtract(const Duration(days: 6));

    final results = await Future.wait([
      _saleRepo.getSales(from: todayStart, to: todayEnd),
      _saleRepo.getSales(from: weekStart, to: todayEnd),
    ]);

    final todayTotals = SalesPeriodTotals.from(results[0]);
    final todayCompleted = results[0].where((s) => !s.isVoided).toList();

    final trendData = _buildTrendData(results[1], todayStart);

    List<Product> products;
    try {
      products = await _productRepo.getAllProducts();
    } catch (_) {
      products = [];
    }
    final todayCost = _calculateCost(todayCompleted, products);

    return HomeData(
      todayRevenue: todayTotals.netRevenue,
      trendData: trendData,
      todaySales: todayCompleted,
      todaySalesCount: todayTotals.salesCount,
      todayCost: todayCost,
      costReady: true,
    );
  }

  List<double> _buildTrendData(List<Sale> weekSales, DateTime todayStart) {
    final dailyRevenue = List<double>.filled(7, 0.0);
    for (final sale in weekSales) {
      if (sale.isVoided) continue;
      final dayDiff = todayStart
          .difference(
            DateTime(
              sale.createdAt.year,
              sale.createdAt.month,
              sale.createdAt.day,
            ),
          )
          .inDays;
      if (dayDiff >= 0 && dayDiff < 7) {
        dailyRevenue[6 - dayDiff] += sale.totalAmount.value;
      }
    }
    return dailyRevenue;
  }

  static Money _calculateCost(List<Sale> todaySales, List<Product> products) {
    final costById = <String, Money>{};
    for (final p in products) {
      costById[p.id] = p.cost;
    }
    var totalCost = Money.zero;
    for (final sale in todaySales) {
      for (final item in sale.items) {
        final cost = costById[item.productId] ?? Money.zero;
        totalCost = totalCost + cost * item.qty;
      }
    }
    return totalCost;
  }
}
