import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_sparkline.dart';

void main() {
  group('HomeSparkline', () {
    testWidgets('renders without error with empty data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HomeSparkline(data: [])),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeSparkline), findsOneWidget);
    });

    testWidgets('renders bar chart with single data point', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HomeSparkline(data: [100])),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeSparkline), findsOneWidget);
    });

    testWidgets('renders sparkline with two data points', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HomeSparkline(data: [100, 200])),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(HomeSparkline), findsOneWidget);
    });

    testWidgets('renders without error when all values are equal', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeSparkline(data: [50, 50, 50, 50, 50, 50, 50]),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without error with all zeros', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HomeSparkline(data: [0, 0, 0, 0, 0, 0, 0])),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('still paints CustomPaint when all values are 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HomeSparkline(data: [0, 0, 0, 0, 0, 0, 0])),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
