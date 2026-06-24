import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';

void main() {
  group('StickyActionBar', () {
    testWidgets('renders primary button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyActionBar(primaryLabel: 'Save', onPrimary: () {}),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('renders secondary button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyActionBar(
              primaryLabel: 'Save',
              onPrimary: () {},
              secondaryLabel: 'Cancel',
              onSecondary: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders danger button when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyActionBar(
              primaryLabel: 'Save',
              onPrimary: () {},
              dangerLabel: 'Delete',
              onDanger: () {},
            ),
          ),
        ),
      );

      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyActionBar(
              primaryLabel: 'Save',
              onPrimary: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('primary button is disabled when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyActionBar(
              primaryLabel: 'Save',
              onPrimary: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('calls onPrimary when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StickyActionBar(
              primaryLabel: 'Save',
              onPrimary: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
