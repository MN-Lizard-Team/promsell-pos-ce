import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/charts/daily_revenue_bar_chart.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  group('DailyRevenueBarChart', () {
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
        wrap(const DailyRevenueBarChart(dailyRevenue: [], currency: 'THB')),
      );

      expect(find.byType(DailyRevenueBarChart), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders a Card when dailyRevenue has data', (tester) async {
      final data = [
        DailyRevenue(date: DateTime(2026, 7, 1), revenue: 1000, count: 5),
        DailyRevenue(date: DateTime(2026, 7, 2), revenue: 1500, count: 8),
      ];

      await tester.pumpWidget(
        wrap(DailyRevenueBarChart(dailyRevenue: data, currency: 'THB')),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Daily Revenue')), findsOneWidget);
    });

    testWidgets('handles all-zero revenue without a chart scale error', (
      tester,
    ) async {
      final data = [
        DailyRevenue(date: DateTime(2026, 7, 1), revenue: 0, count: 0),
        DailyRevenue(date: DateTime(2026, 7, 2), revenue: 0, count: 0),
      ];

      await tester.pumpWidget(
        wrap(DailyRevenueBarChart(dailyRevenue: data, currency: 'THB')),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(Card), findsOneWidget);
    });
  });
}
