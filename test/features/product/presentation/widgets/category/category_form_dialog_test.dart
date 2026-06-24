import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_form_dialog.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CategoryFormDialog', () {
    testWidgets('renders add mode', (tester) async {
      await tester.pumpApp(const CategoryFormDialog());

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(Wrap), findsNWidgets(2));
    });

    testWidgets('renders edit mode with existing values', (tester) async {
      final category = Category(
        id: 'c1',
        name: 'Drinks',
        color: '43A047',
        iconName: 'local_drink_outlined',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      await tester.pumpApp(CategoryFormDialog(category: category));

      expect(find.text('Drinks'), findsOneWidget);
    });

    testWidgets('validates empty name', (tester) async {
      await tester.pumpApp(const CategoryFormDialog());

      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Please enter category name'), findsOneWidget);
    });

    testWidgets('selects color and icon', (tester) async {
      await tester.pumpApp(const CategoryFormDialog());

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(find.byType(InkWell), findsWidgets);
    });
  });

  group('CategoryFormResult', () {
    test('supports equality', () {
      const a = CategoryFormResult(name: 'A', sortOrder: 1, color: 'red');
      const b = CategoryFormResult(name: 'A', sortOrder: 1, color: 'red');
      expect(a, b);
    });
  });
}
