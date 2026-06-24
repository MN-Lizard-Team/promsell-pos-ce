import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_badge.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/section_card.dart';

void main() {
  group('AppBadge', () {
    testWidgets('renders label for success type', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(label: 'Active', type: BadgeType.success),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders with icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'Warning',
              type: BadgeType.warning,
              icon: Icons.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
    });

    testWidgets('renders all badge types', (tester) async {
      for (final type in BadgeType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppBadge(label: 'Test', type: type),
            ),
          ),
        );

        expect(find.text('Test'), findsOneWidget);
      }
    });
  });

  group('AppEmptyState', () {
    testWidgets('renders icon and title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(icon: Icons.inbox, title: 'No items'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('renders message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.inbox,
              title: 'No items',
              message: 'Add some items to get started',
            ),
          ),
        ),
      );

      expect(find.text('Add some items to get started'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.inbox,
              title: 'No items',
              actionLabel: 'Add',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('does not render message in compact mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              child: AppEmptyState(
                icon: Icons.inbox,
                title: 'No items',
                message: 'Should not show',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Should not show'), findsNothing);
    });
  });

  group('SectionCard', () {
    testWidgets('renders child inside card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionCard(child: Text('Content'))),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
