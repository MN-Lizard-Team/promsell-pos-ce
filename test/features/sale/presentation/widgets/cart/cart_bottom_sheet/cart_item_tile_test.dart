import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_item_tile.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../../../helpers/mocks.dart';
import '../../../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;

  final tProduct = Product(
    id: 'p1',
    name: 'Coffee',
    price: 50,
    stock: 10,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    when(() => mockCartBloc.state).thenReturn(const CartState());
  });

  group('CartItemTile', () {
    testWidgets('renders product name and price', (tester) async {
      final item = CartItem(product: tProduct, qty: 2);
      await tester.pumpApp(
        CartItemTile(
          item: item,
          currency: '฿',
          settings: const Settings(),
          onIncrement: () {},
          onDecrement: () {},
          onQtyTap: () {},
          onDelete: () {},
        ),
        cartBloc: mockCartBloc,
      );

      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('calls onIncrement when plus tapped', (tester) async {
      var incremented = false;
      final item = CartItem(product: tProduct, qty: 1);
      await tester.pumpApp(
        CartItemTile(
          item: item,
          currency: '฿',
          settings: const Settings(),
          onIncrement: () => incremented = true,
          onDecrement: () {},
          onQtyTap: () {},
          onDelete: () {},
        ),
        cartBloc: mockCartBloc,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      expect(incremented, isTrue);
    });

    testWidgets('calls onDecrement when minus tapped', (tester) async {
      var decremented = false;
      final item = CartItem(product: tProduct, qty: 2);
      await tester.pumpApp(
        CartItemTile(
          item: item,
          currency: '฿',
          settings: const Settings(),
          onIncrement: () {},
          onDecrement: () => decremented = true,
          onQtyTap: () {},
          onDelete: () {},
        ),
        cartBloc: mockCartBloc,
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
      expect(decremented, isTrue);
    });

    testWidgets('calls onDelete when delete tapped', (tester) async {
      var deleted = false;
      final item = CartItem(product: tProduct, qty: 1);
      await tester.pumpApp(
        CartItemTile(
          item: item,
          currency: '฿',
          settings: const Settings(),
          onIncrement: () {},
          onDecrement: () {},
          onQtyTap: () {},
          onDelete: () => deleted = true,
        ),
        cartBloc: mockCartBloc,
      );

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();
      expect(deleted, isTrue);
    });

    testWidgets('shows discount indicator when item has discount', (
      tester,
    ) async {
      final item = CartItem(
        product: tProduct,
        qty: 2,
        discountType: 'PERCENT',
        discountValue: 10,
      );
      await tester.pumpApp(
        CartItemTile(
          item: item,
          currency: '฿',
          settings: const Settings(),
          onIncrement: () {},
          onDecrement: () {},
          onQtyTap: () {},
          onDelete: () {},
        ),
        cartBloc: mockCartBloc,
      );

      expect(find.textContaining('฿-'), findsOneWidget);
    });
  });
}
