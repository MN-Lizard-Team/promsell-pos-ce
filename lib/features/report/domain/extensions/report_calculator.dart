import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

extension ReportFilterExtension on List<Sale> {
  List<Sale> get completedSales => where((s) => !s.isVoided).toList();

  List<Sale> get voidedSales => where((s) => s.isVoided).toList();
}

extension ReportCalculator on List<Sale> {
  double get netRevenue =>
      completedSales.fold(0.0, (sum, s) => sum + s.totalAmount);

  double get voidedTotal =>
      voidedSales.fold(0.0, (sum, s) => sum + s.totalAmount);

  Map<String, double> byPaymentMethod() {
    final map = <String, double>{};
    for (final s in completedSales) {
      final key = normalizePaymentMethod(s.paymentMethod);
      map[key] = (map[key] ?? 0) + s.totalAmount;
    }
    return map;
  }

  Map<String, int> topProducts() {
    final qtyById = <String, int>{};
    final nameById = <String, String>{};
    for (final s in completedSales) {
      for (final item in s.items) {
        nameById[item.productId] = item.productName;
        qtyById[item.productId] = (qtyById[item.productId] ?? 0) + item.qty;
      }
    }
    final sorted = qtyById.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(
      sorted.take(5).map((e) => MapEntry(nameById[e.key] ?? e.key, e.value)),
    );
  }
}
