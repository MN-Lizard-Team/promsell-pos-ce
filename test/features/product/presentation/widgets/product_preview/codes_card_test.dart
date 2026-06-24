import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/codes_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CodesCard', () {
    testWidgets('renders N/A when SKU and barcode are null', (tester) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: 50,
            stock: 10,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('N/A'), findsNWidgets(2));
    });

    testWidgets('renders SKU when available', (tester) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: 50,
            stock: 10,
            sku: 'SKU123',
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('SKU123'), findsOneWidget);
    });

    testWidgets('renders barcode when available', (tester) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: 50,
            stock: 10,
            barcode: '1234567890',
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('1234567890'), findsNWidgets(2));
    });
  });
}
