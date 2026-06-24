import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_info_block.dart';

import '../../../../../helpers/pump_app.dart';

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

  group('ProductInfoBlock', () {
    testWidgets('renders product name in row layout', (tester) async {
      await tester.pumpApp(ProductInfoBlock(product: product, currency: '฿'));

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('฿50'), findsOneWidget);
    });

    testWidgets('renders product name in grid layout', (tester) async {
      await tester.pumpApp(
        ProductInfoBlock(
          product: product,
          currency: '฿',
          layout: ProductInfoLayout.grid,
        ),
      );

      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('renders product name in compact layout', (tester) async {
      await tester.pumpApp(
        ProductInfoBlock(
          product: product,
          currency: '฿',
          layout: ProductInfoLayout.compact,
        ),
      );

      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('renders category name when provided', (tester) async {
      await tester.pumpApp(
        ProductInfoBlock(
          product: product,
          currency: '฿',
          categoryName: 'Drinks',
        ),
      );

      expect(find.text('Drinks'), findsOneWidget);
    });

    testWidgets('renders SKU when available', (tester) async {
      final productWithSku = product.copyWith(sku: 'SKU123');
      await tester.pumpApp(
        ProductInfoBlock(product: productWithSku, currency: '฿'),
      );

      expect(find.textContaining('SKU123'), findsOneWidget);
    });

    testWidgets('calls onNameTap when name tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        ProductInfoBlock(
          product: product,
          currency: '฿',
          onNameTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Coffee'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
