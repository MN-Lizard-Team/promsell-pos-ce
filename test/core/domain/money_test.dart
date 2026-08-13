import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

void main() {
  group('Money', () {
    test('fromDouble rounds to satang', () {
      expect(Money.fromDouble(1.00).satang, 100);
      expect(Money.fromDouble(1.01).satang, 101);
      expect(Money.fromDouble(9.99).satang, 999);
      // Half-up via *100 + 0.5 truncation path for common decimals.
      expect(Money.fromDouble(0.10).satang, 10);
      expect(Money.fromDouble(0.01).satang, 1);
    });

    test('value and flags', () {
      expect(Money.zero.isZero, isTrue);
      expect(Money.fromDouble(1).isPositive, isTrue);
      expect((-Money.fromDouble(1)).isNegative, isTrue);
      expect(Money.fromDouble(12.5).value, 12.5);
    });

    test('arithmetic + - * clamp negate', () {
      final a = Money.fromDouble(10);
      final b = Money.fromDouble(3);
      expect(a + b, Money.fromDouble(13));
      expect(a - Money.fromDouble(15), Money.zero); // clamped
      expect(a.subtractUnclamped(Money.fromDouble(15)).satang, -500);
      expect(a * 2, Money.fromDouble(20));
      expect(a * 0.333, Money.fromDouble(3.33)); // half-up
      expect((-a).satang, -1000);
      expect(Money.fromDouble(-2).clampToZero(), Money.zero);
    });

    test('comparisons and compareTo', () {
      final a = Money.fromDouble(5);
      final b = Money.fromDouble(7);
      expect(a < b, isTrue);
      expect(a <= b, isTrue);
      expect(b > a, isTrue);
      expect(b >= a, isTrue);
      expect(a.compareTo(b), lessThan(0));
      expect(b.compareTo(a), greaterThan(0));
      expect(a.compareTo(Money.fromDouble(5)), 0);
    });

    test('toString', () {
      expect(Money.fromDouble(9.5).toString(), 'Money(9.50)');
    });

    test('equality via props', () {
      expect(Money.fromDouble(1), Money.fromDouble(1));
      expect(Money.fromDouble(1) == Money.fromDouble(2), isFalse);
    });
  });
}
