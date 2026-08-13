import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_quick_stats_strip.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  group('ReportQuickStatsStrip', () {
    testWidgets('renders nothing when all secondary stats are zero', (
      tester,
    ) async {
      const totals = SalesPeriodTotals(
        netRevenue: Money.zero,
        voidedTotal: Money.zero,
        salesCount: 0,
        voidCount: 0,
        vatAmount: Money.zero,
        discountAmount: Money.zero,
        paymentBreakdown: {},
        paymentCounts: {},
      );
      await tester.pumpWidget(
        wrap(const ReportQuickStatsStrip(totals: totals, currency: 'THB')),
      );
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('renders voided chip when voidCount > 0', (tester) async {
      final totals = SalesPeriodTotals(
        netRevenue: Money.zero,
        voidedTotal: Money.fromDouble(50),
        salesCount: 0,
        voidCount: 1,
        vatAmount: Money.zero,
        discountAmount: Money.zero,
        paymentBreakdown: const {},
        paymentCounts: const {},
      );
      await tester.pumpWidget(
        wrap(ReportQuickStatsStrip(totals: totals, currency: 'THB')),
      );
      expect(find.textContaining('Voided'), findsOneWidget);
    });

    testWidgets('renders VAT and discount chips when non-zero', (tester) async {
      final totals = SalesPeriodTotals(
        netRevenue: Money.zero,
        voidedTotal: Money.zero,
        salesCount: 0,
        voidCount: 0,
        vatAmount: Money.fromDouble(7),
        discountAmount: Money.fromDouble(5),
        paymentBreakdown: const {},
        paymentCounts: const {},
      );
      await tester.pumpWidget(
        wrap(ReportQuickStatsStrip(totals: totals, currency: 'THB')),
      );
      expect(find.textContaining('VAT'), findsOneWidget);
      expect(find.textContaining('Discount'), findsOneWidget);
    });
  });
}
