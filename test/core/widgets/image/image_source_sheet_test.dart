import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_source_sheet.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('showImageSourceSheet', () {
    testWidgets('shows gallery and camera options', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showImageSourceSheet(context, hasImage: false),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('shows remove option when hasImage is true', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showImageSourceSheet(context, hasImage: true),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('returns gallery action when tapped', (tester) async {
      ImageSourceAction? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showImageSourceSheet(context, hasImage: false);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).at(0));
      await tester.pumpAndSettle();

      expect(result, ImageSourceAction.gallery);
    });

    testWidgets('returns camera action when tapped', (tester) async {
      ImageSourceAction? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showImageSourceSheet(context, hasImage: false);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).at(1));
      await tester.pumpAndSettle();

      expect(result, ImageSourceAction.camera);
    });

    testWidgets('returns remove action when tapped', (tester) async {
      ImageSourceAction? result;
      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                result = await showImageSourceSheet(context, hasImage: true);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).at(2));
      await tester.pumpAndSettle();

      expect(result, ImageSourceAction.remove);
    });
  });
}
