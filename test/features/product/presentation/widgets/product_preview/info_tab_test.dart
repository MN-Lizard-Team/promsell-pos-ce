import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/info_tab.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(80),
    stock: 10,
    isActive: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 2),
  );

  group('InfoTab', () {
    testWidgets('renders category name when category provided', (tester) async {
      final category = Category(
        id: 'c1',
        name: 'Drinks',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      await tester.pumpApp(InfoTab(product: product, category: category));

      expect(find.text('Drinks'), findsOneWidget);
    });

    testWidgets('renders "No category" when category is null', (tester) async {
      await tester.pumpApp(InfoTab(product: product, category: null));

      expect(find.text('No category'), findsOneWidget);
    });

    testWidgets('renders created and updated dates', (tester) async {
      await tester.pumpApp(InfoTab(product: product, category: null));

      expect(find.textContaining('Jan 1, 2025'), findsOneWidget);
      expect(find.textContaining('Jan 2, 2025'), findsOneWidget);
    });

    testWidgets('renders description when present', (tester) async {
      final p = product.copyWith(description: 'Best coffee ever');
      await tester.pumpApp(InfoTab(product: p, category: null));

      expect(find.text('Best coffee ever'), findsOneWidget);
    });

    testWidgets('renders empty description placeholder when null', (
      tester,
    ) async {
      await tester.pumpApp(InfoTab(product: product, category: null));

      expect(find.text('No description'), findsOneWidget);
    });

    testWidgets('renders CodesCard with SKU and barcode', (tester) async {
      final p = product.copyWith(sku: 'SKU123', barcode: 'BC456');
      await tester.pumpApp(InfoTab(product: p, category: null));

      expect(find.text('SKU123'), findsOneWidget);
      expect(find.text('BC456'), findsWidgets);
    });

    testWidgets('does not render removed fields (Tax, Weight, Size)', (
      tester,
    ) async {
      await tester.pumpApp(InfoTab(product: product, category: null));

      expect(find.byIcon(Icons.percent), findsNothing);
      expect(find.byIcon(Icons.monitor_weight), findsNothing);
      expect(find.byIcon(Icons.square_foot), findsNothing);
    });

    testWidgets('renders brand when present', (tester) async {
      final p = product.copyWith(brand: 'Acme');
      await tester.pumpApp(InfoTab(product: p, category: null));

      expect(find.text('Acme'), findsOneWidget);
      expect(find.byIcon(Icons.business_outlined), findsOneWidget);
    });

    testWidgets('renders recommended status', (tester) async {
      final p = product.copyWith(isRecommended: true);
      await tester.pumpApp(InfoTab(product: p, category: null));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders supplier when present', (tester) async {
      final p = product.copyWith(supplier: 'Bean Co');
      await tester.pumpApp(InfoTab(product: p, category: null));

      expect(find.text('Bean Co'), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('renders options summary when option groups exist', (
      tester,
    ) async {
      final group = const ProductOptionGroup(
        id: 'g1',
        productId: 'p1',
        name: 'Size',
        isRequired: true,
        options: [],
      );
      final p = product.copyWith(optionGroups: [group]);
      await tester.pumpApp(InfoTab(product: p, category: null));

      expect(find.text('Size'), findsOneWidget);
    });
  });
}
