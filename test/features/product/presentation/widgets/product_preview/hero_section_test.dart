import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/hero_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('HeroSection', () {
    final product = Product(
      id: 'p1',
      name: 'Coffee',
      price: 80,
      stock: 10,
      isActive: true,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    testWidgets('renders product name and active status', (tester) async {
      await tester.pumpApp(HeroSection(product: product));

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders no category label', (tester) async {
      await tester.pumpApp(HeroSection(product: product));

      expect(find.text('No category'), findsOneWidget);
    });

    testWidgets('renders category name when provided', (tester) async {
      final category = Category(
        id: 'c1',
        name: 'Drinks',
        color: '0xFF0000',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      await tester.pumpApp(HeroSection(product: product, category: category));

      expect(find.text('Drinks'), findsOneWidget);
    });

    testWidgets('renders inactive status for inactive product', (tester) async {
      final inactiveProduct = product.copyWith(isActive: false);
      await tester.pumpApp(HeroSection(product: inactiveProduct));

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });

  group('StatusChip', () {
    testWidgets('renders active chip', (tester) async {
      await tester.pumpApp(const StatusChip(active: true));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('renders inactive chip', (tester) async {
      await tester.pumpApp(const StatusChip(active: false));

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
