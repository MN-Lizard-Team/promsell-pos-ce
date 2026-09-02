import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

void main() {
  final now = DateTime(2026, 1, 1);
  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(50),
    stock: 10,
    isActive: true,
    trackStock: true,
    createdAt: now,
    updatedAt: now,
  );
  final item = CartItem(product: product, qty: 2);

  test('CartProductAdded props', () {
    final e = CartProductAdded(product, qty: 3, allowOversell: true);
    expect(e.props, [product, 3, true, const []]);
    expect(e, CartProductAdded(product, qty: 3, allowOversell: true));
  });

  test('CartRestored.fromCartState copies meta', () {
    final state = CartState(
      items: [item],
      note: 'n',
      cartDiscountType: 'PERCENT',
      cartDiscountValue: 10,
      orderType: 'dinein',
      orderChannel: 'grab',
      tableId: 't1',
      serviceChargeRate: 5,
      customerId: 'c1',
      promotionId: 'pr1',
      promotionDiscountAmount: 12,
    );
    final e = CartRestored.fromCartState(state);
    expect(e.note, 'n');
    expect(e.orderType, 'dinein');
    expect(e.tableId, 't1');
    expect(e.customerId, 'c1');
    expect(e.promotionId, 'pr1');
    expect(e.promotionDiscountAmount, 12);
    expect(e.items, hasLength(1));
  });

  test('line and bulk events props', () {
    expect(const CartProductRemoved('p1', lineId: 'l1').props, ['p1', 'l1']);
    expect(
      const CartItemQtyChanged(productId: 'p1', qty: 4, lineId: 'l1').props,
      ['p1', 4, false, 'l1'],
    );
    expect(const CartCleared().props, [false]);
    expect(CartItemRestored(item).props, [item]);
    expect(CartItemDuplicated(item).props, [item]);
    expect(
      const CartItemDiscountChanged(
        productId: 'p1',
        discountType: 'PERCENT',
        discountValue: 5,
        lineId: 'l',
      ).props,
      ['p1', 'PERCENT', 5.0, 'l'],
    );
    expect(const CartItemDiscountCleared('p1').props, ['p1', null]);
    expect(
      const CartDiscountChanged(
        discountType: 'AMOUNT',
        discountValue: 10,
      ).props,
      ['AMOUNT', 10.0],
    );
    expect(const CartDiscountCleared().props, isEmpty);
    expect(const CartNoteChanged('hi').props, ['hi']);
    expect(CartProductsRefreshed([product]).props, [
      [product],
    ]);
    expect(const CartBarcodeScanned('123').props, ['123']);
    expect(const CartBulkItemsRemoved(['a', 'b']).props, [
      ['a', 'b'],
    ]);
    expect(const CartBulkItemDiscountsCleared(['a']).props, [
      ['a'],
    ]);
    expect(const CartItemsReordered(['x', 'y']).props, [
      ['x', 'y'],
    ]);
    expect(
      const CartItemNoteChanged(productId: 'p1', note: 'n', lineId: 'l').props,
      ['p1', 'n', 'l'],
    );
    expect(const CartTableAssigned('t').props, ['t']);
    expect(const CartGuestCountChanged(4).props, [4]);
    expect(const CartGuestCountChanged(null).props, [null]);
    expect(const CartCustomerSet('c').props, ['c']);
    expect(const CartPromotionSet('p').props, ['p']);
    expect(const CartPromotionRecompute().props, isEmpty);
    expect(const CartOrderTypeChanged('dinein').props, ['dinein']);
    expect(const CartOrderChannelChanged('walkin').props, ['walkin']);
    expect(const CartExternalOrderRefChanged('ext').props, ['ext']);
    expect(const CartServiceChargeRateChanged(7.5).props, [7.5]);
    expect(const CartPaymentLockChanged(true).props, [true]);
  });
}
