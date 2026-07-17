import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_write_helpers.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

void main() {
  final product = Product(
    id: 'p1',
    name: 'A',
    price: Money.fromDouble(100),
    stock: 10,
    isActive: true,
    trackStock: true,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );

  test('allocateLineVat last line gets residual satang', () {
    final items = [
      CartItem(product: product, qty: 1, lineId: 'a'),
      CartItem(product: product, qty: 1, lineId: 'b'),
      CartItem(product: product, qty: 1, lineId: 'c'),
    ];
    // 1.00 baht VAT over three equal lines → 0.33 + 0.33 + 0.34
    final parts = SaleWriteHelpers.allocateLineVat(
      items: items,
      headerVat: Money.fromDouble(1),
      vatMode: 'EXCLUSIVE',
      vatRate: 7,
    );
    expect(parts.length, 3);
    final sum = parts.fold(Money.zero, (a, b) => a + b);
    expect(sum, Money.fromDouble(1));
    expect(parts[0].satang + parts[1].satang + parts[2].satang, 100);
  });

  test('allocateLineVat zero when no vat', () {
    final items = [CartItem(product: product, qty: 2, lineId: 'a')];
    final parts = SaleWriteHelpers.allocateLineVat(
      items: items,
      headerVat: Money.zero,
      vatMode: 'NONE',
      vatRate: 0,
    );
    expect(parts.single, Money.zero);
  });

  test('serialize and parse selected options round-trip', () {
    final opts = [
      SelectedProductOption(
        groupId: 'g1',
        groupName: 'Size',
        optionId: 'o1',
        optionName: 'L',
        priceDelta: Money.fromDouble(10),
      ),
    ];
    final json = SaleWriteHelpers.serializeSelectedOptions(opts);
    expect(json, isNotNull);
    final back = SaleWriteHelpers.parseSelectedOptions(json);
    expect(back, hasLength(1));
    expect(back.single.optionName, 'L');
  });

  test('parseSelectedOptions tolerates bad json', () {
    expect(SaleWriteHelpers.parseSelectedOptions('not-json'), isEmpty);
    expect(SaleWriteHelpers.parseSelectedOptions(null), isEmpty);
  });
}
