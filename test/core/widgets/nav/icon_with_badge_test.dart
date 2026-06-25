import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/nav/bottom_navigation_bar/icon_with_badge.dart';

void main() {
  group('IconWithBadge', () {
    testWidgets('renders icon without badge when badgeCount is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeColor: Colors.red,
              isActive: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byType(Positioned), findsNothing);
    });

    testWidgets('renders badge dot when badgeCount is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeCount: 0,
              badgeColor: Colors.red,
              isActive: false,
            ),
          ),
        ),
      );

      expect(find.byType(Positioned), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('renders badge with number when badgeCount > 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeCount: 5,
              badgeColor: Colors.red,
              isActive: false,
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders 99+ when badgeCount > 99', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeCount: 150,
              badgeColor: Colors.red,
              isActive: false,
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
    });
  });

  group('IconWithBadge fixes', () {
    testWidgets('badge opacity is lower when active (F5)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeCount: 5,
              badgeColor: Colors.red,
              isActive: true,
            ),
          ),
        ),
      );

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 0.7);
    });

    testWidgets('badge opacity is full when inactive (F5)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeCount: 5,
              badgeColor: Colors.red,
              isActive: false,
            ),
          ),
        ),
      );

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, 1.0);
    });

    testWidgets('badge text is white on dark badge color (F8)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeCount: 5,
              badgeColor: Colors.black,
              isActive: false,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('5'));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('badge text is black on light badge color (F8)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconWithBadge(
              icon: Icons.home,
              color: Colors.black,
              badgeCount: 5,
              badgeColor: Colors.yellow,
              isActive: false,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('5'));
      expect(text.style?.color, Colors.black);
    });
  });
}
