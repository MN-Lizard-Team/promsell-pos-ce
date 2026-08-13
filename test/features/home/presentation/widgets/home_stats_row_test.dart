import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_stats_row.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('HomeStatsRow', () {
    testWidgets('displays revenue, cost, and profit labels', (tester) async {
      await tester.pumpApp(
        HomeStatsRow(
          revenue: Money.fromDouble(1000),
          cost: Money.fromDouble(400),
          profit: Money.fromDouble(600),
        ),
      );

      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Profit'), findsOneWidget);
    });

    testWidgets('shows compact format for large revenue', (tester) async {
      await tester.pumpApp(
        HomeStatsRow(
          revenue: Money.fromDouble(1500000),
          cost: Money.fromDouble(500000),
          profit: Money.fromDouble(1000000),
        ),
      );

      expect(find.text('฿1.5M'), findsOneWidget);
    });

    testWidgets('shows compact format for thousands', (tester) async {
      await tester.pumpApp(
        HomeStatsRow(
          revenue: Money.fromDouble(3500),
          cost: Money.fromDouble(500),
          profit: Money.fromDouble(3000),
        ),
      );

      expect(find.text('฿3.5k'), findsOneWidget);
    });

    testWidgets('uses error color for negative profit', (tester) async {
      await tester.pumpApp(
        HomeStatsRow(
          revenue: Money.fromDouble(100),
          cost: Money.fromDouble(300),
          profit: Money.fromDouble(-200),
        ),
      );

      final profitFinder = find.text('Profit');
      expect(profitFinder, findsOneWidget);

      final statCard = tester.widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('-฿200.00'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      );
      expect(statCard.style.color, isNotNull);
    });

    testWidgets('shows shimmer when loading', (tester) async {
      await tester.pumpApp(
        const HomeStatsRow(
          revenue: Money.zero,
          cost: Money.zero,
          profit: Money.zero,
          isLoading: true,
        ),
      );

      expect(find.byType(HomeStatsRow), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Profit'), findsOneWidget);
    });

    testWidgets('uses custom currency symbol when provided', (tester) async {
      await tester.pumpApp(
        HomeStatsRow(
          revenue: Money.fromDouble(1500000),
          cost: Money.fromDouble(500000),
          profit: Money.fromDouble(1000000),
          currency: '\$',
        ),
      );

      expect(find.text('\$1.5M'), findsOneWidget);
    });
  });
}
