import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

void main() {
  test('json round-trip and copyWith', () {
    final o = SelectedProductOption(
      optionId: 'o1',
      optionName: 'Large',
      groupId: 'g1',
      groupName: 'Size',
      priceDelta: Money.fromDouble(10),
    );
    expect(o.totalPriceDelta, Money.fromDouble(10));
    final json = o.toJson();
    final back = SelectedProductOption.fromJson(json);
    expect(back, o);

    final c = o.copyWith(optionName: 'XL', priceDelta: Money.fromDouble(15));
    expect(c.optionName, 'XL');
    expect(c.priceDelta, Money.fromDouble(15));
    expect(c.optionId, 'o1');
  });

  test('fromJson defaults', () {
    final o = SelectedProductOption.fromJson(const {
      'optionId': 'x',
      'priceDelta': 2.5,
    });
    expect(o.optionName, '');
    expect(o.groupId, '');
    expect(o.priceDelta, Money.fromDouble(2.5));
  });
}
