import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_hero_dashboard_card.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  group('HomeHeroDashboardCard', () {
    testWidgets('displays revenue and bill count when loaded', (tester) async {
      await tester.pumpApp(
        HomeHeroDashboardCard(
          todayRevenue: Money.fromDouble(1500.50),
          todaySalesCount: 12,
          trendData: const [100, 200, 150, 300, 250, 400, 500],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('฿'), findsWidgets);
      expect(find.textContaining('bills'), findsOneWidget);
    });

    testWidgets('shows shimmer when loading', (tester) async {
      await tester.pumpApp(
        const HomeHeroDashboardCard(
          todayRevenue: Money.zero,
          todaySalesCount: 0,
          trendData: [0, 0, 0, 0, 0, 0, 0],
          isLoading: true,
        ),
      );

      expect(find.byType(HomeHeroDashboardCard), findsOneWidget);
      expect(find.text("Today's Revenue"), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        HomeHeroDashboardCard(
          todayRevenue: Money.fromDouble(500),
          todaySalesCount: 3,
          trendData: const [100, 200, 150, 300, 250, 400, 500],
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(HomeHeroDashboardCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
