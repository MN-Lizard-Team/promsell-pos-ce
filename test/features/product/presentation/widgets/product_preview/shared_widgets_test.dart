import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('PreviewCard', () {
    testWidgets('renders icon, title and child', (tester) async {
      await tester.pumpApp(
        const PreviewCard(
          icon: Icons.inventory,
          title: 'Stock',
          child: Text('Content'),
        ),
      );

      expect(find.byIcon(Icons.inventory), findsOneWidget);
      expect(find.text('Stock'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders icon and title', (tester) async {
      await tester.pumpApp(
        const SectionHeader(icon: Icons.info, title: 'Info'),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });
  });

  group('InfoRow', () {
    testWidgets('renders label and value', (tester) async {
      await tester.pumpApp(const InfoRow(label: 'Name', value: Text('Coffee')));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
    });
  });
}
