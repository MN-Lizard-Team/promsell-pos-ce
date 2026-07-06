import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

void main() {
  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('CartState restaurant fields', () {
    test('default orderType is dinein', () {
      const state = CartState();
      expect(state.orderType, 'dinein');
      expect(state.orderChannel, 'walkin');
    });

    test('default serviceChargeAmount is 0', () {
      const state = CartState();
      expect(state.serviceChargeAmount, 0.0);
    });

    test('serviceChargeAmount calculates from rate', () {
      final state = CartState(
        items: [CartItem(product: product, qty: 2)],
        serviceChargeRate: 10.0,
      );
      expect(state.total, 100.0);
      expect(state.serviceChargeAmount, 10.0);
    });

    test('grandTotal includes service charge', () {
      final state = CartState(
        items: [CartItem(product: product, qty: 2)],
        serviceChargeRate: 10.0,
      );
      expect(state.grandTotal, 110.0);
    });

    test('serviceChargeAmount is 0 when rate is null', () {
      final state = CartState(items: [CartItem(product: product, qty: 2)]);
      expect(state.serviceChargeAmount, 0.0);
      expect(state.grandTotal, state.total);
    });

    test('copyWith updates orderType', () {
      const state = CartState();
      final updated = state.copyWith(orderType: 'delivery');
      expect(updated.orderType, 'delivery');
    });

    test('copyWith updates orderChannel', () {
      const state = CartState();
      final updated = state.copyWith(orderChannel: 'phone');
      expect(updated.orderChannel, 'phone');
    });

    test('copyWith updates tableId', () {
      const state = CartState();
      final updated = state.copyWith(tableId: 't3');
      expect(updated.tableId, 't3');
    });

    test('copyWith clears tableId when set to null', () {
      const state = CartState(tableId: 't3');
      final updated = state.copyWith(tableId: null);
      expect(updated.tableId, isNull);
    });

    test('copyWith clears externalOrderRef when set to null', () {
      const state = CartState(externalOrderRef: 'REF123');
      final updated = state.copyWith(externalOrderRef: null);
      expect(updated.externalOrderRef, isNull);
    });

    test('copyWith clears serviceChargeRate when set to null', () {
      const state = CartState(serviceChargeRate: 10.0);
      final updated = state.copyWith(serviceChargeRate: null);
      expect(updated.serviceChargeRate, isNull);
    });
  });
}
