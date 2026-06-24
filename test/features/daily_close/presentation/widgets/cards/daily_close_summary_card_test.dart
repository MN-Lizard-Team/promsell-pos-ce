import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/cards/daily_close_summary_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('DailyCloseSummaryCard', () {
    const dailyClose = DailyClose(
      id: 'dc1',
      closeDate: '2026-06-08',
      salesCount: 10,
      voidCount: 1,
      totalRevenue: 5000,
      totalVoid: 200,
      paymentBreakdown: {'cash': 3000, 'card': 2000},
    );

    testWidgets('renders summary card', (tester) async {
      await tester.pumpApp(const DailyCloseSummaryCard(dailyClose: dailyClose));

      expect(find.byType(DailyCloseSummaryCard), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
    });

    testWidgets('renders sales count', (tester) async {
      await tester.pumpApp(const DailyCloseSummaryCard(dailyClose: dailyClose));

      expect(find.text('Sales count'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });
  });
}
