import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_hero_image.dart';

void main() {
  group('ProductHeroImage', () {
    testWidgets('renders placeholder icon when no image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ProductHeroImage())),
      );

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.text('Tap to add image'), findsOneWidget);
    });

    testWidgets('renders FAB for image selection', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ProductHeroImage())),
      );

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProductHeroImage(isLoading: true)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onTap when FAB tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ProductHeroImage(onTap: () => tapped = true)),
        ),
      );

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
