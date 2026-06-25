import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_app_bars.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CategorySearchAppBar', () {
    testWidgets('renders TextField with hint text', (tester) async {
      await tester.pumpApp(
        CategorySearchAppBar(
          controller: TextEditingController(),
          onChanged: (_) {},
          onClose: () {},
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('calls onClose when clear button tapped', (tester) async {
      var closed = false;
      final controller = TextEditingController();
      await tester.pumpApp(
        CategorySearchAppBar(
          controller: controller,
          onChanged: (_) {},
          onClose: () => closed = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(closed, isTrue);
    });

    testWidgets('calls onChanged when text changes', (tester) async {
      String? query;
      final controller = TextEditingController();
      await tester.pumpApp(
        CategorySearchAppBar(
          controller: controller,
          onChanged: (value) => query = value,
          onClose: () {},
        ),
      );

      await tester.enterText(find.byType(TextField), 'Drinks');
      await tester.pump();

      expect(query, 'Drinks');
    });
  });

  group('CategoryBulkAppBar', () {
    testWidgets('renders selected count when count > 0', (tester) async {
      await tester.pumpApp(
        CategoryBulkAppBar(
          selectedCount: 3,
          onClose: () {},
          onBulkDelete: () {},
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('hides delete icon when count is 0', (tester) async {
      await tester.pumpApp(
        CategoryBulkAppBar(
          selectedCount: 0,
          onClose: () {},
          onBulkDelete: () {},
        ),
      );

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
