import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_discount_policy.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

void main() {
  test('percent clamps to max', () {
    final settings = const Settings().copyWith(maxDiscountPercent: 30);
    final r = CartDiscountPolicy.clamp(
      settings: settings,
      type: 'PERCENT',
      value: 80,
    );
    expect(r, isNotNull);
    expect(r!.$2, 30);
  });

  test('amount clamps to max', () {
    final settings = const Settings().copyWith(
      maxDiscountAmount: Money.fromDouble(25),
    );
    final r = CartDiscountPolicy.clamp(
      settings: settings,
      type: 'AMOUNT',
      value: 40,
    );
    expect(r!.$2, 25);
  });

  test('non-positive returns null', () {
    expect(
      CartDiscountPolicy.clamp(
        settings: const Settings(),
        type: 'PERCENT',
        value: 0,
      ),
      isNull,
    );
  });
}
