import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_page_indicator.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_toolbar_button.dart';

void main() {
  group('ImageViewerPageIndicator', () {
    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageViewerPageIndicator(count: 3, currentIndex: 1),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('renders single dot for count=1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImageViewerPageIndicator(count: 1, currentIndex: 0),
          ),
        ),
      );

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });
  });

  group('ImageViewerToolbarButton', () {
    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageViewerToolbarButton(icon: Icons.share, onTap: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageViewerToolbarButton(
              icon: Icons.share,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
