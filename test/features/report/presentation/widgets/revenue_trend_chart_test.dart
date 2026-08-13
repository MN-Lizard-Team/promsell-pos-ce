import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/charts/revenue_trend_chart.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  group('RevenueTrendChart', () {
    Widget wrap(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders nothing when dailyRevenue is empty', (tester) async {
      await tester.pumpWidget(
        wrap(const RevenueTrendChart(dailyRevenue: [], currency: 'THB')),
      );

      expect(find.byType(RevenueTrendChart), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders a Card when dailyRevenue has data', (tester) async {
      final data = [
        DailyRevenue(date: DateTime(2026, 7, 1), revenue: 1000, count: 5),
        DailyRevenue(date: DateTime(2026, 7, 2), revenue: 1500, count: 8),
        DailyRevenue(date: DateTime(2026, 7, 3), revenue: 800, count: 3),
      ];

      await tester.pumpWidget(
        wrap(RevenueTrendChart(dailyRevenue: data, currency: 'THB')),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
