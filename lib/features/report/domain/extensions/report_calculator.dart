import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';

extension ReportFilterExtension on List<Sale> {
  List<Sale> get completedSales => where((s) => !s.isVoided).toList();

  List<Sale> get voidedSales => where((s) => s.isVoided).toList();
}

/// Qty-ranked top product with secondary revenue (line subtotals).
class TopProductStat {
  const TopProductStat({
    required this.displayName,
    required this.qty,
    required this.revenue,
  });

  final String displayName;
  final int qty;
  final double revenue;
}

extension ReportCalculator on List<Sale> {
  /// Single source of truth for period money metrics (shared with Daily Close).
  SalesPeriodTotals get periodTotals => SalesPeriodTotals.from(this);

  Money get netRevenue => periodTotals.netRevenue;

  Money get voidedTotal => periodTotals.voidedTotal;

  Map<String, double> byPaymentMethod() => periodTotals.paymentBreakdown;

  Map<String, int> paymentMethodCounts() => periodTotals.paymentCounts;

  /// Top products ranked by **qty** (unchanged); [TopProductStat.revenue] is
  /// sum of [SaleItem.subtotal] for completed sales only.
  List<TopProductStat> topProductStats({int limit = 5}) {
    final qtyById = <String, int>{};
    final revById = <String, double>{};
    final nameById = <String, String>{};
    for (final s in completedSales) {
      for (final item in s.items) {
        nameById[item.productId] = item.productName;
        qtyById[item.productId] = (qtyById[item.productId] ?? 0) + item.qty;
        revById[item.productId] =
            (revById[item.productId] ?? 0) + item.subtotal.value;
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
      return TopProductStat(
        displayName: display,
        qty: e.value,
        revenue: revById[e.key] ?? 0,
      );
    }).toList();
  }

  /// Compatibility map name → qty (rank still by qty via [topProductStats]).
  Map<String, int> topProducts() => {
    for (final s in topProductStats()) s.displayName: s.qty,
  };
}
