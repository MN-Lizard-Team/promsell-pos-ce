import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/category_filter_chips.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CategoryFilterChips', () {
    final categories = [
      Category(
        id: 'c1',
        name: 'Drinks',
        sortOrder: 0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      Category(
        id: 'c2',
        name: 'Food',
        sortOrder: 1,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ];

    testWidgets('renders all categories plus All and No category chips', (
      tester,
    ) async {
      await tester.pumpApp(
        CategoryFilterChips(
          categories: categories,
          selectedCategoryId: null,
          onCategorySelected: (_) {},
        ),
      );

      expect(find.byType(ChoiceChip), findsNWidgets(4));
    });

    testWidgets('calls onCategorySelected with category id', (tester) async {
      String? selected;
      await tester.pumpApp(
        CategoryFilterChips(
          categories: categories,
          selectedCategoryId: null,
          onCategorySelected: (id) => selected = id,
        ),
      );

      await tester.tap(find.text('Drinks'));
      await tester.pump();
      expect(selected, 'c1');
    });

    testWidgets('calls onCategorySelected with null for All', (tester) async {
      String? selected = 'c1';
      await tester.pumpApp(
        CategoryFilterChips(
          categories: categories,
          selectedCategoryId: 'c1',
          onCategorySelected: (id) => selected = id,
        ),
      );

      await tester.tap(find.text('All'));
      await tester.pump();
      expect(selected, isNull);
    });

    testWidgets(
      'calls onCategorySelected with kNoCategoryFilter for No category',
      (tester) async {
        String? selected;
        await tester.pumpApp(
          CategoryFilterChips(
            categories: categories,
            selectedCategoryId: null,
            onCategorySelected: (id) => selected = id,
          ),
        );

        await tester.tap(find.text('No category'));
        await tester.pump();
        expect(selected, '__none__');
      },
    );
  });
}
