import 'package:promsell_pos_ce/core/domain/money.dart';

/// Domain math for cart-level discount amount (AH-2.3 / Wave D).
///
/// Same formula as [CartState._computeCartDiscountAmount] / DraftCart:
/// PERCENT of [itemsSubtotal], or flat clamped to subtotal.
abstract final class CartDiscountMath {
  CartDiscountMath._();

  /// Amount from type/value against post-line [itemsSubtotal].
  static Money amountFromTypeValue({
    required String? type,
    required double? value,
    required Money itemsSubtotal,
  }) {
    if (type == null || value == null || value <= 0) {
      return Money.zero;
    }
    if (type.toUpperCase() == 'PERCENT') {
      final pct = value.clamp(0.0, 100.0);
      return itemsSubtotal * (pct / 100);
    }
    final flat = Money.fromDouble(value).clampToZero();
    return flat <= itemsSubtotal ? flat : itemsSubtotal;
  }

  /// Cap [promotionDiscount] so it cannot exceed post-cart base.
  static Money clampPromotionToBase({
    required Money itemsSubtotal,
    required Money cartDiscountAmount,
    required Money promotionDiscount,
  }) {
    final base = (itemsSubtotal - cartDiscountAmount).clampToZero();
    final promo = promotionDiscount.clampToZero();
    return promo <= base ? promo : base;
  }

  /// Service charge from rate on net after cart + promo discounts.
  static Money serviceChargeFromRate({
    required Money itemsSubtotal,
    required Money cartDiscountAmount,
    required Money promotionDiscountAmount,
    required double serviceChargeRate,
  }) {
    final rate = serviceChargeRate.clamp(0.0, 100.0);
    if (rate <= 0) return Money.zero;
    final net = (itemsSubtotal - cartDiscountAmount - promotionDiscountAmount)
        .clampToZero();
    return net * (rate / 100);
  }
}
