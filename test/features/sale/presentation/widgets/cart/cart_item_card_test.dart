import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CartItemCard', () {
    final product = Product(
      id: 'p1',
      name: 'Test Product',
      price: 99.0,
      stock: 10,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final item = CartItem(product: product, qty: 2);

    testWidgets('renders product name', (tester) async {
      await tester.pumpApp(
        CartItemCard(
          item: item,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () {},
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('renders quantity', (tester) async {
      await tester.pumpApp(
        CartItemCard(
          item: item,
          currency: 'THB',
          onImageTap: () {},
          onRowTap: () {},
          onDecrement: () {},
          onIncrement: () {},
          onDelete: () {},
        ),
      );

      expect(find.text('2'), findsOneWidget);
    });
  });
}
