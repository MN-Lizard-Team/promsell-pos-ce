import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/system_info_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('SystemInfoCard', () {
    testWidgets('renders product id and dates', (tester) async {
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      await tester.pumpApp(
        SystemInfoCard(
          product: Product(
            id: 'prod-123',
            name: 'Test',
            price: 100,
            stock: 5,
            isActive: true,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        ),
      );

      expect(find.text('prod-123'), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('renders formatted dates with cached locale (P9)', (
      tester,
    ) async {
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      await tester.pumpApp(
        SystemInfoCard(
          product: Product(
            id: 'prod-123',
            name: 'Test',
            price: 100,
            stock: 5,
            isActive: true,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        ),
      );

      expect(find.textContaining('Jan'), findsWidgets);
      expect(find.textContaining('10:30'), findsNWidgets(2));
    });

    testWidgets('product ID uses fontSize 13 not 12 (U9)', (tester) async {
      final createdAt = DateTime(2024, 1, 15, 10, 30);
      await tester.pumpApp(
        SystemInfoCard(
          product: Product(
            id: 'prod-123',
            name: 'Test',
            price: 100,
            stock: 5,
            isActive: true,
            createdAt: createdAt,
            updatedAt: createdAt,
          ),
        ),
      );

      final selectableText = tester.widget<SelectableText>(
        find.byType(SelectableText).first,
      );
      expect(selectableText.style?.fontSize, 13);
    });
  });
}
