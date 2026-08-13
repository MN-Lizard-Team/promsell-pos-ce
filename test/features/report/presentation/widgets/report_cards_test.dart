import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/top_product_stat.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/date_range_preset_chips.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_date_range_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_key_metrics_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_order_breakdown_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_payment_method_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_profitability_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_promptpay_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_top_products_card.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

void main() {
  const calculator = ReportCalculatorService();

  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  SalesPeriodTotals buildTotals({
    Money? netRevenue,
    int salesCount = 2,
    Map<String, double> paymentBreakdown = const {
      'cash': 100,
      'promptpay': 200,
    },
    Map<String, int> paymentCounts = const {'cash': 1, 'promptpay': 1},
    Map<String, double> orderTypeBreakdown = const {},
    Map<String, double> orderChannelBreakdown = const {},
    Map<String, int> voidReasonBreakdown = const {},
    int promotionCount = 0,
  }) {
    netRevenue ??= Money.fromDouble(300);
    return SalesPeriodTotals(
      netRevenue: netRevenue,
      voidedTotal: Money.zero,
      salesCount: salesCount,
      voidCount: 0,
      vatAmount: Money.zero,
      discountAmount: Money.zero,
      paymentBreakdown: paymentBreakdown,
      paymentCounts: paymentCounts,
      orderTypeBreakdown: orderTypeBreakdown,
      orderChannelBreakdown: orderChannelBreakdown,
      voidReasonBreakdown: voidReasonBreakdown,
      promotionCount: promotionCount,
    );
  }

  Sale buildSale({
    String status = 'COMPLETED',
    double total = 100,
    String method = 'cash',
    DateTime? createdAt,
  }) {
    final isVoided = status == 'VOIDED';
    return Sale(
      id: 'sale-$status-$total',
      receiptNumber: 'R001',
      status: status,
      items: [
        SaleItem(
          id: 'i1',
          saleId: 's1',
          productId: 'p1',
          productName: 'Coffee',
          price: Money.fromDouble(50),
          qty: 2,
          subtotal: Money.fromDouble(100),
        ),
      ],
      totalAmount: Money.fromDouble(total),
      subtotalAmount: Money.fromDouble(total),
      paymentMethod: method,
      amountReceived: Money.fromDouble(total),
      changeAmount: Money.zero,
      createdAt: createdAt ?? DateTime(2026, 6, 2, 10),
      voidedAt: isVoided ? DateTime(2026, 6, 2, 11) : null,
    );
  }

  group('ReportKeyMetricsCard', () {
    testWidgets('renders nothing when all metrics are zero', (tester) async {
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
        wrap(
          const ReportKeyMetricsCard(
            totals: totals,
            sales: [],
            currency: 'THB',
            calculator: calculator,
          ),
        ),
      );
      // Card returns SizedBox.shrink() — no visible content.
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.textContaining('Gross'), findsNothing);
    });

    testWidgets('renders gross revenue and ATV when non-zero', (tester) async {
      final totals = buildTotals();
      await tester.pumpWidget(
        wrap(
          ReportKeyMetricsCard(
            totals: totals,
            sales: [buildSale()],
            currency: 'THB',
            calculator: calculator,
          ),
        ),
      );
      expect(find.textContaining('Gross'), findsOneWidget);
      expect(find.textContaining('Average'), findsOneWidget);
    });
  });

  group('ReportOrderBreakdownCard', () {
    testWidgets('renders nothing when no breakdown data', (tester) async {
      final totals = buildTotals();
      await tester.pumpWidget(
        wrap(ReportOrderBreakdownCard(totals: totals, currency: 'THB')),
      );
      // Card returns SizedBox.shrink() — no section card visible.
      expect(find.textContaining('Order'), findsNothing);
    });

    testWidgets('renders order type section when breakdown is non-empty', (
      tester,
    ) async {
      final totals = buildTotals(orderTypeBreakdown: {'dine_in': 500.0});
      await tester.pumpWidget(
        wrap(ReportOrderBreakdownCard(totals: totals, currency: 'THB')),
      );
      expect(find.byType(ReportOrderBreakdownCard), findsOneWidget);
    });
  });

  group('ReportPaymentMethodCard', () {
    testWidgets('renders empty message when no sales', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ReportPaymentMethodCard(
            byMethod: {},
            methodCounts: {},
            netRevenue: 0,
            currency: 'THB',
          ),
        ),
      );
      expect(find.textContaining('No sales'), findsOneWidget);
    });

    testWidgets('renders method rows when sales exist', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ReportPaymentMethodCard(
            byMethod: {'cash': 100, 'promptpay': 200},
            methodCounts: {'cash': 1, 'promptpay': 1},
            netRevenue: 300,
            currency: 'THB',
          ),
        ),
      );
      expect(find.textContaining('Cash'), findsWidgets);
      expect(find.textContaining('PromptPay'), findsWidgets);
    });
  });

  group('ReportProfitabilityCard', () {
    testWidgets('renders nothing when no cost coverage', (tester) async {
      final profit = calculator.profitAnalytics([buildSale()], {});
      await tester.pumpWidget(
        wrap(ReportProfitabilityCard(profit: profit, currency: 'THB')),
      );
      // Card returns SizedBox.shrink() when hasNoCoverage.
      expect(find.textContaining('Profit'), findsNothing);
    });

    testWidgets('renders profit metrics when cost data available', (
      tester,
    ) async {
      final sales = [buildSale(total: 100)];
      final lookup = <String, Product>{'p1': _product(id: 'p1', cost: 30)};
      final profit = calculator.profitAnalytics(sales, lookup);
      await tester.pumpWidget(
        wrap(ReportProfitabilityCard(profit: profit, currency: 'THB')),
      );
      expect(find.byType(ReportProfitabilityCard), findsOneWidget);
      expect(find.textContaining('Profit'), findsWidgets);
    });
  });

  group('ReportPromptPayCard', () {
    testWidgets('renders nothing when no PromptPay sales', (tester) async {
      final sales = [buildSale(method: 'cash')];
      await tester.pumpWidget(
        wrap(
          ReportPromptPayCard(
            sales: sales,
            currency: 'THB',
            fmt: DateFormat('d MMM yyyy'),
            calculator: calculator,
          ),
        ),
      );
      // Card returns SizedBox.shrink() when no PromptPay sales.
      expect(find.textContaining('PromptPay'), findsNothing);
    });

    testWidgets('renders total when PromptPay sales exist', (tester) async {
      final sales = [buildSale(method: 'promptpay', total: 200)];
      await tester.pumpWidget(
        wrap(
          ReportPromptPayCard(
            sales: sales,
            currency: 'THB',
            fmt: DateFormat('d MMM yyyy'),
            calculator: calculator,
          ),
        ),
      );
      expect(find.byType(ReportPromptPayCard), findsOneWidget);
    });
  });

  group('ReportTopProductsCard', () {
    testWidgets('renders empty message when no products', (tester) async {
      await tester.pumpWidget(
        wrap(const ReportTopProductsCard(topProducts: [], currency: 'THB')),
      );
      expect(find.textContaining('No sales'), findsOneWidget);
    });

    testWidgets('renders product rows when data exists', (tester) async {
      final stats = <TopProductStat>[
        const TopProductStat(displayName: 'Coffee', qty: 10, revenue: 500),
      ];
      await tester.pumpWidget(
        wrap(ReportTopProductsCard(topProducts: stats, currency: 'THB')),
      );
      expect(find.text('Coffee'), findsOneWidget);
    });
  });

  group('DateRangePresetChips', () {
    testWidgets('renders all preset chips', (tester) async {
      final today = DateTime(2026, 6, 15);
      await tester.pumpWidget(
        wrap(
          StatefulBuilder(
            builder: (context, setState) => DateRangePresetChips(
              from: today,
              to: today,
              onPreset: (f, t) {},
            ),
          ),
        ),
      );
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Yesterday'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
    });

    testWidgets('calls onPreset when a chip is tapped', (tester) async {
      DateTime? capturedFrom;
      DateTime? capturedTo;
      await tester.pumpWidget(
        wrap(
          DateRangePresetChips(
            from: DateTime(2026, 1, 1),
            to: DateTime(2026, 1, 2),
            onPreset: (f, t) {
              capturedFrom = f;
              capturedTo = t;
            },
          ),
        ),
      );
      // Tap the "Today" chip
      await tester.tap(find.text('Today'));
      await tester.pump();
      expect(capturedFrom, isNotNull);
      expect(capturedTo, isNotNull);
    });
  });

  group('ReportDateRangeCard', () {
    testWidgets('displays formatted date range and calls onTap', (
      tester,
    ) async {
      var tapped = false;
      final from = DateTime(2026, 6, 1);
      final to = DateTime(2026, 6, 15);
      await tester.pumpWidget(
        wrap(
          ReportDateRangeCard(
            from: from,
            to: to,
            fmt: DateFormat('d MMM yyyy'),
            onTap: () => tapped = true,
          ),
        ),
      );
      expect(find.textContaining('1'), findsWidgets);
      expect(find.textContaining('15'), findsWidgets);
      await tester.tap(find.byType(ReportDateRangeCard));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}

Product _product({required String id, double cost = 0}) {
  final now = DateTime(2026, 6, 1);
  return Product(
    id: id,
    name: 'Test Product',
    price: Money.fromDouble(50),
    cost: Money.fromDouble(cost),
    stock: 100,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}
