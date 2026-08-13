import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/draft_naming.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

void main() {
  final fixed = DateTime(2026, 1, 1, 9, 5);

  group('DraftNaming.autoName', () {
    test('tableId wins over time', () {
      expect(
        DraftNaming.autoName(tableId: 'T-5', itemCount: 3, now: fixed),
        'T-5',
      );
    });

    test('empty bill is B-HHmm', () {
      expect(DraftNaming.autoName(itemCount: 0, now: fixed), 'B-0905');
    });

    test('non-empty is B-HHmm · N', () {
      expect(DraftNaming.autoName(itemCount: 2, now: fixed), 'B-0905 · 2');
    });

    test('blank table falls through to time', () {
      expect(
        DraftNaming.autoName(tableId: '  ', itemCount: 0, now: fixed),
        'B-0905',
      );
    });
  });

  group('DraftNaming.forNewEmptyBill', () {
    test('matches empty autoName', () {
      expect(DraftNaming.forNewEmptyBill(now: fixed), 'B-0905');
    });
  });

  group('DraftNaming.autoParkName', () {
    test('uses tableId from cart', () {
      const cart = CartState(tableId: 'T-5', items: []);
      expect(DraftNaming.autoParkName(cart), 'T-5');
    });

    test('uses time and item count without table', () {
      final product = Product(
        id: 'p1',
        name: 'Water',
        price: Money.fromDouble(10),
        stock: 10,
        isActive: true,
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final cart = CartState(items: [CartItem(product: product, qty: 2)]);
      expect(DraftNaming.autoParkName(cart, now: fixed), 'B-0905 · 2');
    });
  });

  group('DraftNaming.resolveParkName', () {
    final product = Product(
      id: 'p1',
      name: 'Water',
      price: Money.fromDouble(10),
      stock: 10,
      isActive: true,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );
    final cart = CartState(items: [CartItem(product: product, qty: 1)]);

    test('keeps existing name when no explicit', () {
      expect(
        DraftNaming.resolveParkName(
          cart: cart,
          existingName: 'VIP',
          now: fixed,
        ),
        'VIP',
      );
    });

    test('auto when no existing and no explicit', () {
      expect(DraftNaming.resolveParkName(cart: cart, now: fixed), 'B-0905 · 1');
    });

    test('explicit non-empty wins', () {
      expect(
        DraftNaming.resolveParkName(
          cart: cart,
          explicitName: 'Table 7',
          existingName: 'VIP',
          now: fixed,
        ),
        'Table 7',
      );
    });

    test('explicit empty falls to auto', () {
      expect(
        DraftNaming.resolveParkName(
          cart: cart,
          explicitName: '  ',
          existingName: 'VIP',
          now: fixed,
        ),
        'B-0905 · 1',
      );
    });
  });
}
