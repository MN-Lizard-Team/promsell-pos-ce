import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

void main() {
  final tProduct = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('CartItem with selectedOptions', () {
    test('default selectedOptions is empty', () {
      final item = CartItem(product: tProduct, qty: 2);
      expect(item.selectedOptions, isEmpty);
    });

    test('rawSubtotal includes options price delta', () {
      const option = SelectedProductOption(
        optionId: 'opt1',
        optionName: 'Extra Shot',
        groupId: 'grp1',
        groupName: 'Add-ons',
        priceDelta: 15.0,
      );
      final item = CartItem(
        product: tProduct,
        qty: 2,
        selectedOptions: const [option],
      );
      expect(item.rawSubtotal, (50 + 15) * 2);
    });

    test('rawSubtotal with multiple options', () {
      const options = [
        SelectedProductOption(
          optionId: 'opt1',
          optionName: 'Extra Shot',
          groupId: 'grp1',
          groupName: 'Add-ons',
          priceDelta: 15.0,
        ),
        SelectedProductOption(
          optionId: 'opt2',
          optionName: 'Whipped Cream',
          groupId: 'grp2',
          groupName: 'Toppings',
          priceDelta: 10.0,
        ),
      ];
      final item = CartItem(
        product: tProduct,
        qty: 1,
        selectedOptions: options,
      );
      expect(item.rawSubtotal, (50 + 15 + 10) * 1);
    });

    test('copyWith updates selectedOptions', () {
      final item = CartItem(product: tProduct, qty: 1);
      const option = SelectedProductOption(
        optionId: 'opt1',
        optionName: 'Extra Shot',
        groupId: 'grp1',
        groupName: 'Add-ons',
        priceDelta: 15.0,
      );
      final updated = item.copyWith(selectedOptions: const [option]);
      expect(updated.selectedOptions.length, 1);
      expect(updated.selectedOptions.first.optionName, 'Extra Shot');
    });

    test('equality includes selectedOptions', () {
      const option = SelectedProductOption(
        optionId: 'opt1',
        optionName: 'Extra Shot',
        groupId: 'grp1',
        groupName: 'Add-ons',
        priceDelta: 15.0,
      );
      final a = CartItem(
        product: tProduct,
        qty: 1,
        selectedOptions: const [option],
      );
      final b = CartItem(
        product: tProduct,
        qty: 1,
        selectedOptions: const [option],
      );
      expect(a, equals(b));
    });

    test('SelectedProductOption toJson/fromJson roundtrip', () {
      const option = SelectedProductOption(
        optionId: 'opt1',
        optionName: 'Extra Shot',
        groupId: 'grp1',
        groupName: 'Add-ons',
        priceDelta: 15.0,
      );
      final json = option.toJson();
      final restored = SelectedProductOption.fromJson(json);
      expect(restored, option);
    });
  });
}
