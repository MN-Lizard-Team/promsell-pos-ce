import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_loading_overlay.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('AppLoadingOverlay', () {
    testWidgets('renders child when not loading', (tester) async {
      await tester.pumpApp(
        const AppLoadingOverlay(isLoading: false, child: Text('Content')),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpApp(
        const AppLoadingOverlay(isLoading: true, child: Text('Content')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows label when provided and loading', (tester) async {
      await tester.pumpApp(
        const AppLoadingOverlay(
          isLoading: true,
          label: 'Saving...',
          child: Text('Content'),
        ),
      );

      expect(find.text('Saving...'), findsOneWidget);
    });

    testWidgets('does not show label when not loading', (tester) async {
      await tester.pumpApp(
        const AppLoadingOverlay(
          isLoading: false,
          label: 'Saving...',
          child: Text('Content'),
        ),
      );

      expect(find.text('Saving...'), findsNothing);
    });
  });
}
