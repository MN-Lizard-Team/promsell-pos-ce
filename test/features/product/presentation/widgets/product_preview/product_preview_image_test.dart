import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/product_preview_image.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ProductPreviewImage', () {
    final product = Product(
      id: 'p1',
      name: 'Coffee',
      price: 80,
      stock: 10,
      isActive: true,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    testWidgets('renders active status chip via PreviewOverlay', (
      tester,
    ) async {
      await tester.pumpApp(
        SizedBox(
          height: 260,
          child: Stack(
            children: [PreviewOverlay(product: product, hasImage: false)],
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('does not show product name (handled by SliverAppBar)', (
      tester,
    ) async {
      await tester.pumpApp(ProductPreviewImage(product: product));

      expect(find.text('Coffee'), findsNothing);
    });

    testWidgets('renders category name when provided via PreviewOverlay', (
      tester,
    ) async {
      final category = Category(
        id: 'c1',
        name: 'Drinks',
        color: '0xFF0000',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      await tester.pumpApp(
        SizedBox(
          height: 260,
          child: Stack(
            children: [
              PreviewOverlay(
                product: product,
                category: category,
                hasImage: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Drinks'), findsOneWidget);
    });

    testWidgets(
      'renders inactive status for inactive product via PreviewOverlay',
      (tester) async {
        final inactiveProduct = product.copyWith(isActive: false);
        await tester.pumpApp(
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                PreviewOverlay(product: inactiveProduct, hasImage: false),
              ],
            ),
          ),
        );

        expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      },
    );

    // -- No-image placeholder --

    testWidgets('no-image uses category icon fallback', (tester) async {
      final category = Category(
        id: 'c1',
        name: 'Drinks',
        iconName: 'restaurant_outlined',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      await tester.pumpApp(
        ProductPreviewImage(product: product, category: category),
      );

      expect(find.byIcon(Icons.restaurant_outlined), findsWidgets);
    });

    testWidgets('no-image icon size scales with height', (tester) async {
      await tester.pumpApp(ProductPreviewImage(product: product, height: 300));

      final icon = tester.widget<Icon>(find.byIcon(Icons.inventory_2));
      expect(icon.size, closeTo(300 * 0.17, 0.01));
    });

    testWidgets('no-image icon container size scales with height', (
      tester,
    ) async {
      await tester.pumpApp(ProductPreviewImage(product: product, height: 300));

      final containers = tester.widgetList<Container>(find.byType(Container));
      final circleContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle,
      );
      final size = tester.getSize(find.byWidget(circleContainer));
      expect(size.width, closeTo(300 * 0.37, 0.01));
      expect(size.height, closeTo(300 * 0.37, 0.01));
    });

    testWidgets('no-image area has Semantics label', (tester) async {
      await tester.pumpApp(ProductPreviewImage(product: product));

      expect(find.bySemanticsLabel('No product image'), findsOneWidget);
    });

    testWidgets('_hasImage is false when only thumbnail path exists', (
      tester,
    ) async {
      final productWithOnlyThumb = product.copyWith(
        imageThumbnailPath: '/data/thumb/image.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithOnlyThumb));

      // Should show no-image placeholder, not image area
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('didUpdateWidget resets state when product changes', (
      tester,
    ) async {
      final productA = product.copyWith(imageUrl: 'https://example.com/a.png');
      final productB = product.copyWith(
        id: 'p2',
        imageUrl: 'https://example.com/b.png',
      );

      await tester.pumpApp(ProductPreviewImage(product: productA));
      await tester.pump();

      // Rebuild with different product
      await tester.pumpApp(ProductPreviewImage(product: productB));
      await tester.pump();

      // Should still render image area (not crash)
      expect(find.byType(Image), findsOneWidget);
    });

    // -- Image area --

    testWidgets('image area has Semantics label', (tester) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/test.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));
      await tester.pump();

      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Product image',
      );
      expect(semantics, findsOneWidget);
    });

    testWidgets('image does not use ResizeImage (full resolution)', (
      tester,
    ) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/test.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isNot(isA<ResizeImage>()));
    });

    testWidgets('image has frameBuilder and errorBuilder configured', (
      tester,
    ) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/nonexistent.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.frameBuilder, isNotNull);
      expect(image.errorBuilder, isNotNull);
    });

    testWidgets('local file image has errorBuilder for fallback', (
      tester,
    ) async {
      final productWithBadPath = product.copyWith(
        imagePath: '/nonexistent/path/to/image.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithBadPath));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.errorBuilder, isNotNull);
    });

    testWidgets('network image shows skeleton during loading', (tester) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/test-image.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));
      await tester.pump(const Duration(milliseconds: 250));

      // Skeleton should be visible after 200ms delay while still loading
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    // -- Hero animation removed (no Hero in widget) --

    testWidgets('no Hero widget in tree', (tester) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/test.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));

      expect(find.byType(Hero), findsNothing);
    });

    // -- Tap hint --

    testWidgets('tap hint icon is present in widget tree', (tester) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/test.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));

      expect(find.byIcon(Icons.zoom_out_map), findsOneWidget);
    });

    testWidgets('tap hint text is present', (tester) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/test.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));

      expect(find.text('Tap to zoom'), findsOneWidget);
    });

    testWidgets('tap hint has Semantics widget', (tester) async {
      final productWithUrl = product.copyWith(
        imageUrl: 'https://example.com/test.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithUrl));

      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Tap to zoom',
      );
      expect(semantics, findsOneWidget);
    });

    // -- Static hasImage method --

    testWidgets('hasImage returns true when imagePath is set', (tester) async {
      final p = product.copyWith(imagePath: '/data/image.png');
      expect(ProductPreviewImage.hasImage(p), isTrue);
    });

    testWidgets('hasImage returns true when imageUrl is set', (tester) async {
      final p = product.copyWith(imageUrl: 'https://example.com/img.png');
      expect(ProductPreviewImage.hasImage(p), isTrue);
    });

    testWidgets('hasImage returns false when no image paths', (tester) async {
      expect(ProductPreviewImage.hasImage(product), isFalse);
    });

    testWidgets('uses full image path not thumbnail', (tester) async {
      final productWithThumb = product.copyWith(
        imagePath: '/data/full/image.png',
        imageThumbnailPath: '/data/thumb/image.png',
      );
      await tester.pumpApp(ProductPreviewImage(product: productWithThumb));

      // Image widget should exist — full image path is used (not thumbnail)
      expect(find.byType(Image), findsOneWidget);
    });

    // -- No ClipRRect --

    testWidgets('no ClipRRect in widget tree', (tester) async {
      await tester.pumpApp(ProductPreviewImage(product: product));

      expect(find.byType(ClipRRect), findsNothing);
    });

    // -- ClipRect for overflow protection --

    testWidgets('uses ClipRect for overflow protection', (tester) async {
      await tester.pumpApp(ProductPreviewImage(product: product));

      expect(find.byType(ClipRect), findsOneWidget);
    });

    // -- StatusChip theme color --

    testWidgets('StatusChip uses theme color not hardcoded green', (
      tester,
    ) async {
      await tester.pumpApp(const StatusChip(active: true));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final color = decoration.color;
      expect(color, isNot(Colors.green.withValues(alpha: 0.85)));
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
