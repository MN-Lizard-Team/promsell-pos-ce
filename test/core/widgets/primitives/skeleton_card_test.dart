import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/skeleton_card.dart';

void main() {
  group('SkeletonCard', () {
    testWidgets('renders with default height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonCard())),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final constraints = container.constraints;
      expect(constraints?.maxHeight, 80);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonCard(height: 120))),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxHeight, 120);
    });
  });

  group('SkeletonList', () {
    testWidgets('renders correct number of skeleton cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonList(itemCount: 3))),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(3));
    });

    testWidgets('renders default 5 items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SkeletonList())),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(5));
    });
  });
}
