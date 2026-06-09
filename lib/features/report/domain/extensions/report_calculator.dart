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
    final topEntries = sorted.take(5).toList();
    final nameCounts = <String, int>{};
    for (final e in topEntries) {
      final name = nameById[e.key] ?? e.key;
      nameCounts[name] = (nameCounts[name] ?? 0) + 1;
    }
    return Map.fromEntries(
      topEntries.map((e) {
        final name = nameById[e.key] ?? e.key;
        final disambiguate = (nameCounts[name] ?? 0) > 1;
        final key = disambiguate
            ? '$name (${e.key.substring(0, e.key.length.clamp(0, 4))})'
            : name;
        return MapEntry(key, e.value);
      }),
    );
  }
}
