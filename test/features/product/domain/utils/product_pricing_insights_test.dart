import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_pricing_insights.dart';

void main() {
  group('ProductPricingInsights.fromMoney', () {
    test('empty cost yields no profit metrics', () {
      final i = ProductPricingInsights.fromMoney(
        price: Money.fromDouble(100),
        cost: null,
      );
      expect(i.hasCost, isFalse);
      expect(i.profit, isNull);
      expect(i.marginPct, isNull);
      expect(i.markupPct, isNull);
      expect(i.isLoss, isFalse);
    });

    test('zero cost is entered — full profit, no markup', () {
      final i = ProductPricingInsights.fromMoney(
        price: Money.fromDouble(100),
        cost: Money.zero,
      );
      expect(i.hasCost, isTrue);
      expect(i.profit, Money.fromDouble(100));
      expect(i.marginPct, closeTo(100, 0.001));
      expect(i.markupPct, isNull);
      expect(i.isLoss, isFalse);
    });

    test('normal margin and markup', () {
      final i = ProductPricingInsights.fromMoney(
        price: Money.fromDouble(50),
        cost: Money.fromDouble(30),
      );
      expect(i.profit, Money.fromDouble(20));
      expect(i.marginPct, closeTo(40, 0.001));
      expect(i.markupPct, closeTo(66.666, 0.01));
      expect(i.isLoss, isFalse);
    });

    test('loss when cost exceeds price', () {
      final i = ProductPricingInsights.fromMoney(
        price: Money.fromDouble(100),
        cost: Money.fromDouble(120),
      );
      expect(i.profit!.isNegative, isTrue);
      expect(i.profit, Money.fromDouble(-20));
      expect(i.marginPct, closeTo(-20, 0.001));
      expect(i.markupPct, closeTo(-16.666, 0.01));
      expect(i.isLoss, isTrue);
    });

    test('cost equal price is loss', () {
      final i = ProductPricingInsights.fromMoney(
        price: Money.fromDouble(50),
        cost: Money.fromDouble(50),
      );
      expect(i.isLoss, isTrue);
      expect(i.profit, Money.zero);
    });
  });

  group('ProductPricingInsights.fromText', () {
    test('blank cost text is empty cost', () {
      final i = ProductPricingInsights.fromText(
        priceText: '10.00',
        costText: '  ',
      );
      expect(i.hasCost, isFalse);
    });

    test('zero string is entered cost', () {
      final i = ProductPricingInsights.fromText(priceText: '10', costText: '0');
      expect(i.hasCost, isTrue);
      expect(i.cost, Money.zero);
    });
  });

  group('priceFromMarkup', () {
    test('+50% on 30 → 45', () {
      final price = ProductPricingInsights.priceFromMarkup(
        Money.fromDouble(30),
        50,
      );
      expect(price, Money.fromDouble(45));
    });

    test('+100% on 25 → 50', () {
      final price = ProductPricingInsights.priceFromMarkup(
        Money.fromDouble(25),
        100,
      );
      expect(price, Money.fromDouble(50));
    });

    test('+20% on 10 → 12', () {
      final price = ProductPricingInsights.priceFromMarkup(
        Money.fromDouble(10),
        20,
      );
      expect(price, Money.fromDouble(12));
    });
  });
}
