import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/image/image_error_placeholder.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ImageErrorPlaceholder', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpApp(const ImageErrorPlaceholder(size: 64));

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
    });

    testWidgets('renders label when enabled', (tester) async {
      await tester.pumpApp(
        const ImageErrorPlaceholder(size: 64, showLabel: true),
      );

      expect(find.text('Image error'), findsOneWidget);
    });
  });
}
