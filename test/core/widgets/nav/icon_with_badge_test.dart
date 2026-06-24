import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/nav/animated_nav_bar/icon_with_badge.dart';

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
}
