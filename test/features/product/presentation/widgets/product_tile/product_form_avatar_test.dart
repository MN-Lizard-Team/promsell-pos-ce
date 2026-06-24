import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_form_avatar.dart';

void main() {
  group('ProductFormAvatar', () {
    testWidgets('renders UnifiedImageWidget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ProductFormAvatar())),
      );

      expect(find.byType(ProductFormAvatar), findsOneWidget);
    });

    testWidgets('shows edit badge when onTap provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProductFormAvatar(onTap: () {})),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('shows loading overlay when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProductFormAvatar(isLoading: true)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ProductSectionLabel', () {
    testWidgets('renders uppercase label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProductSectionLabel(label: 'details')),
        ),
      );

      expect(find.text('DETAILS'), findsOneWidget);
    });
  });
}
