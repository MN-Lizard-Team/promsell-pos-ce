import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/layout/danger_zone_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';

void main() {
  group('DangerZoneCard', () {
    testWidgets('renders title, subtitle, and action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DangerZoneCard(
              icon: Icons.delete,
              title: 'Danger',
              subtitle: 'This will delete everything',
              actionLabel: 'Delete',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Danger'), findsOneWidget);
      expect(find.text('This will delete everything'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('calls onAction when button tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DangerZoneCard(
              icon: Icons.delete,
              title: 'Danger',
              subtitle: 'Subtitle',
              actionLabel: 'Delete',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('FormSectionCard', () {
    testWidgets('renders icon, title, and child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormSectionCard(
              icon: Icons.settings,
              title: 'Settings',
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormSectionCard(
              icon: Icons.settings,
              title: 'Settings',
              trailing: Text('Extra'),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Extra'), findsOneWidget);
    });
  });

  group('ModernToggleCard', () {
    testWidgets('renders title and switch', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernToggleCard(
              icon: Icons.notifications,
              title: 'Notifications',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernToggleCard(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Get alerts',
              value: false,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Get alerts'), findsOneWidget);
    });

    testWidgets('tapping card toggles value', (tester) async {
      var value = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModernToggleCard(
              icon: Icons.notifications,
              title: 'Notifications',
              value: value,
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(value, isTrue);
    });
  });
}
