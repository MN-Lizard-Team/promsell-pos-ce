import 'dart:convert';

import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

/// Pure helpers for sale write/hydrate paths (extracted from datasource).
///
/// No I/O — safe to unit-test without Drift.
abstract final class SaleWriteHelpers {
  SaleWriteHelpers._();

  /// Distribute [headerVat] across lines by subtotal weight; last line residual.
  static List<Money> allocateLineVat({
    required List<CartItem> items,
    required Money headerVat,
    required String vatMode,
    required double vatRate,
  }) {
    if (items.isEmpty || headerVat <= Money.zero || vatRate <= 0) {
      return List<Money>.filled(items.length, Money.zero);
    }
    final weights = items.map((i) => i.subtotal).toList();
    final weightSum = weights.fold(Money.zero, (a, b) => a + b);
    if (weightSum <= Money.zero) {
      return List<Money>.filled(items.length, Money.zero);
    }
    final allocated = <Money>[];
    var remaining = headerVat;
    for (var i = 0; i < items.length; i++) {
      if (i == items.length - 1) {
        allocated.add(remaining.clampToZero());
        break;
      }
      // Proportional share in satang (integer math).
      final shareSatang =
          (headerVat.satang * weights[i].satang) ~/ weightSum.satang;
      final share = Money.fromDouble(shareSatang / 100.0);
      allocated.add(share);
      remaining = remaining - share;
    }
    return allocated;
  }

  static List<SelectedProductOption> parseSelectedOptions(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => SelectedProductOption.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static String? serializeSelectedOptions(List<SelectedProductOption> options) {
    if (options.isEmpty) return null;
    return jsonEncode(options.map((o) => o.toJson()).toList());
  }
}
