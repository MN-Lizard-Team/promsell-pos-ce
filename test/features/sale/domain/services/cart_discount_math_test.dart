import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/cart_discount_math.dart';

void main() {
  group('CartDiscountMath.amountFromTypeValue', () {
    final sub = Money.fromDouble(200);

    test('PERCENT of subtotal', () {
      expect(
        CartDiscountMath.amountFromTypeValue(
          type: 'PERCENT',
          value: 10,
          itemsSubtotal: sub,
        ),
        Money.fromDouble(20),
      );
    });

    test('flat clamps to subtotal', () {
      expect(
        CartDiscountMath.amountFromTypeValue(
          type: 'AMOUNT',
          value: 500,
          itemsSubtotal: sub,
        ),
        sub,
      );
    });

    test('null or non-positive → zero', () {
      expect(
        CartDiscountMath.amountFromTypeValue(
          type: null,
          value: 10,
          itemsSubtotal: sub,
        ),
        Money.zero,
      );
      expect(
        CartDiscountMath.amountFromTypeValue(
          type: 'PERCENT',
          value: 0,
          itemsSubtotal: sub,
        ),
        Money.zero,
      );
    });
  });

  group('CartDiscountMath.clampPromotionToBase', () {
    test('caps promo to post-cart base', () {
      expect(
        CartDiscountMath.clampPromotionToBase(
          itemsSubtotal: Money.fromDouble(100),
          cartDiscountAmount: Money.fromDouble(40),
          promotionDiscount: Money.fromDouble(80),
        ),
        Money.fromDouble(60),
      );
    });
  });

  group('CartDiscountMath.serviceChargeFromRate', () {
    test('SC on net after discounts', () {
      // net = 200 - 20 - 10 = 170 → 10% = 17
      expect(
        CartDiscountMath.serviceChargeFromRate(
          itemsSubtotal: Money.fromDouble(200),
          cartDiscountAmount: Money.fromDouble(20),
          promotionDiscountAmount: Money.fromDouble(10),
          serviceChargeRate: 10,
        ),
        Money.fromDouble(17),
      );
    });

    test('zero rate → zero SC', () {
      expect(
        CartDiscountMath.serviceChargeFromRate(
          itemsSubtotal: Money.fromDouble(200),
          cartDiscountAmount: Money.zero,
          promotionDiscountAmount: Money.zero,
          serviceChargeRate: 0,
        ),
        Money.zero,
      );
    });
  });
}
