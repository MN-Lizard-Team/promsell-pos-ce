import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_hero_image.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  group('ProductHeroImage', () {
    testWidgets('renders placeholder icon when no image', (tester) async {
      await tester.pumpApp(const ProductHeroImage());

      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.text('Tap to add image'), findsOneWidget);
    });

    testWidgets('renders FAB with add icon when no image', (tester) async {
      await tester.pumpApp(const ProductHeroImage());

      expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
    });

    testWidgets('renders FAB with edit icon when image present', (
      tester,
    ) async {
      await tester.pumpApp(const ProductHeroImage(imagePath: '/fake/path.jpg'));

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpApp(const ProductHeroImage(isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onTap when FAB tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(ProductHeroImage(onTap: () => tapped = true));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
