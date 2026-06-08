import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_category_autocomplete.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('ProductCategoryAutocomplete', () {
    testWidgets('renders text field', (tester) async {
      final controller = TextEditingController();
      await tester.pumpApp(
        ProductCategoryAutocomplete(
          controller: controller,
          categories: const ['Food', 'Drink'],
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      controller.dispose();
    });

    testWidgets('shows suggestions when typing', (tester) async {
      final controller = TextEditingController();
      await tester.pumpApp(
        ProductCategoryAutocomplete(
          controller: controller,
          categories: const ['Food', 'Drink', 'Snacks'],
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Fo');
      await tester.pump();

      expect(find.text('Food'), findsOneWidget);
      controller.dispose();
    });
  });
}
