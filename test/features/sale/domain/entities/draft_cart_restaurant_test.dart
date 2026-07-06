import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';

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

  group('DraftCart restaurant fields', () {
    test('default orderType is dinein', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.orderType, 'dinein');
      expect(draft.orderChannel, 'walkin');
    });

    test('serviceChargeAmount is 0 when rate is null', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.serviceChargeAmount, 0.0);
    });

    test('serviceChargeAmount calculates from rate', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        serviceChargeRate: 10.0,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.total, 100.0);
      expect(draft.serviceChargeAmount, 10.0);
    });

    test('grandTotal includes service charge', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        serviceChargeRate: 10.0,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.grandTotal, 110.0);
    });

    test('grandTotal equals total when no service charge', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 2)],
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.grandTotal, draft.total);
    });

    test('can set orderType to delivery', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        orderType: 'delivery',
        orderChannel: 'online',
        externalOrderRef: 'REF123',
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.orderType, 'delivery');
      expect(draft.orderChannel, 'online');
      expect(draft.externalOrderRef, 'REF123');
    });

    test('can set tableId', () {
      final draft = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        tableId: 't5',
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(draft.tableId, 't5');
    });

    test('equality includes restaurant fields', () {
      final a = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        orderType: 'delivery',
        serviceChargeRate: 10.0,
        updatedAt: DateTime(2025, 1, 1),
      );
      final b = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        orderType: 'delivery',
        serviceChargeRate: 10.0,
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(a, equals(b));
    });

    test('inequality when orderType differs', () {
      final a = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        orderType: 'dinein',
        updatedAt: DateTime(2025, 1, 1),
      );
      final b = DraftCart(
        id: 'd1',
        items: [CartItem(product: tProduct, qty: 1)],
        orderType: 'takeaway',
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(a, isNot(equals(b)));
    });
  });
}
