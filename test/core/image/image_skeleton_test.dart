import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/image/image_skeleton.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ImageSkeleton', () {
    testWidgets('renders animated container', (tester) async {
      await tester.pumpApp(const ImageSkeleton(size: 64));

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders with border radius', (tester) async {
      await tester.pumpApp(
        const ImageSkeleton(size: 64, borderRadius: BorderRadius.zero),
      );

      expect(find.byType(ImageSkeleton), findsOneWidget);
    });
  });
}
