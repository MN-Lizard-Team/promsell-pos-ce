import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/image/unified_image_widget.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('UnifiedImageWidget', () {
    testWidgets('renders placeholder when no image', (tester) async {
      await tester.pumpApp(const UnifiedImageWidget(size: 64));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders loading skeleton', (tester) async {
      await tester.pumpApp(const UnifiedImageWidget(size: 64, isLoading: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders with network URL', (tester) async {
      await tester.pumpApp(
        const UnifiedImageWidget(
          size: 64,
          networkUrl: 'https://example.com/img.png',
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
