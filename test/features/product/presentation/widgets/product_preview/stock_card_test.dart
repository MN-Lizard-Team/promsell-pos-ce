import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/stock_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('StockCard', () {
    testWidgets('renders stock info when tracking stock', (tester) async {
      await tester.pumpApp(
        StockCard(
          product: Product(
            id: 'p1',
            name: 'Coffee',
            price: 50,
            cost: 30,
            stock: 10,
            trackStock: true,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          currency: '฿',
        ),
      );

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('shows out of stock when stock is 0', (tester) async {
      await tester.pumpApp(
        StockCard(
          product: Product(
            id: 'p1',
            name: 'Coffee',
            price: 50,
            cost: 30,
            stock: 0,
            trackStock: true,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          currency: '฿',
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows low stock when stock <= 5', (tester) async {
      await tester.pumpApp(
        StockCard(
          product: Product(
            id: 'p1',
            name: 'Coffee',
            price: 50,
            cost: 30,
            stock: 3,
            trackStock: true,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          currency: '฿',
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('shows disabled when trackStock is false', (tester) async {
      await tester.pumpApp(
        StockCard(
          product: Product(
            id: 'p1',
            name: 'Coffee',
            price: 50,
            cost: 30,
            stock: 10,
            trackStock: false,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          currency: '฿',
        ),
      );

      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('shows edit button when onEditStock is provided', (
      tester,
    ) async {
      await tester.pumpApp(
        StockCard(
          product: Product(
            id: 'p1',
            name: 'Coffee',
            price: 50,
            cost: 30,
            stock: 10,
            trackStock: true,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          currency: '฿',
          onEditStock: () {},
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
