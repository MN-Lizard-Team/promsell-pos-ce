import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/table_sales_stat.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_table_breakdown_card.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sales_period_totals.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_key_metrics_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_order_breakdown_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_payment_method_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_profitability_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_promptpay_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_quick_stats_strip.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_top_products_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/summary_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/charts/daily_revenue_bar_chart.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/charts/revenue_trend_chart.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/close_day_cta.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_stagger.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Scrollable content for the Report overview tab.
///
/// Layout order flows from most important to most detailed:
/// hero → quick stats → chart → key metrics → profitability →
/// payment/products → promptpay/close → order breakdown.
class ReportOverviewContent extends StatelessWidget {
  const ReportOverviewContent({
    super.key,
    required this.dateHeader,
    required this.totals,
    required this.sales,
    required this.previousPeriodNetRevenue,
    required this.dailyRevenue,
    required this.days,
    required this.currency,
    required this.fmt,
    required this.closeLabel,
    required this.onCloseDay,
    required this.calculator,
    this.profit,
    this.previousProfit,
    this.productLookup = const {},
    this.lastUpdated,
    this.aggregate,
    this.tableBreakdown = const [],
  });

  final Widget dateHeader;
  final SalesPeriodTotals totals;
  final List<Sale> sales;

  /// Previous-period net revenue (baht) powering the hero-card delta.
  /// Callers resolve it from hydrated previous sales or the SQL summary
  /// depending on which data path produced [totals].
  final double previousPeriodNetRevenue;
  final List<DailyRevenue> dailyRevenue;
  final int days;
  final String currency;
  final DateFormat fmt;
  final String closeLabel;
  final VoidCallback onCloseDay;
  final ProfitAnalytics? profit;
  final ProfitAnalytics? previousProfit;
  final Map<String, Product> productLookup;

  /// SQL-aggregated bundle for long ranges. When set, item/customer-derived
  /// cards read from it instead of scanning [sales] (which is empty then).
  final ReportAggregate? aggregate;
  final ReportCalculatorService calculator;
  final DateTime? lastUpdated;
  final List<TableSalesStat> tableBreakdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    var stagger = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportStagger(index: stagger++, child: dateHeader),
        if (lastUpdated != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '• ${DateFormat.Hm().format(lastUpdated!.toLocal())}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        ReportStagger(
          index: stagger++,
          child: SummaryCard(
            title: context.l10n.netRevenue,
            value: totals.netRevenue.value,
            currency: currency,
            subtitle: context.l10n.salesCount(totals.salesCount),
            previousValue: previousPeriodNetRevenue,
            icon: TablerIcons.coins,
            color: theme.colorScheme.primary,
            emphasize: true,
          ),
        ),
        const SizedBox(height: 12),
        ReportStagger(
          index: stagger++,
          child: ReportQuickStatsStrip(
            totals: totals,
            currency: currency,
            profit: profit,
          ),
        ),
        if (days > 1) ...[
          const SizedBox(height: 16),
          ReportStagger(
            index: stagger++,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartHeight = constraints.maxWidth > 840 ? 240.0 : 180.0;
                return days > 14
                    ? RevenueTrendChart(
                        dailyRevenue: dailyRevenue,
                        currency: currency,
                        height: chartHeight,
                      )
                    : DailyRevenueBarChart(
                        dailyRevenue: dailyRevenue,
                        currency: currency,
                        height: chartHeight,
                      );
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        ReportStagger(
          index: stagger++,
          child: ReportKeyMetricsCard(
            totals: totals,
            sales: sales,
            currency: currency,
            calculator: calculator,
            hourlyRevenueOverride: aggregate?.hourlyRevenue,
            uniqueCustomerCountOverride: aggregate?.uniqueCustomers,
            repeatCustomerCountOverride: aggregate?.repeatCustomers,
          ),
        ),
        if (profit != null && !profit!.hasNoCoverage) ...[
          const SizedBox(height: 16),
          ReportStagger(
            index: stagger++,
            child: ReportProfitabilityCard(
              profit: profit!,
              previousProfit: previousProfit,
              currency: currency,
            ),
          ),
        ],
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final payment = ReportStagger(
              index: stagger++,
              child: ReportPaymentMethodCard(
                byMethod: totals.paymentBreakdown,
                methodCounts: totals.paymentCounts,
                netRevenue: totals.netRevenue.value,
                currency: currency,
              ),
            );
            final topProducts = ReportStagger(
              index: stagger++,
              child: ReportTopProductsCard(
                topProducts: aggregate != null
                    ? aggregate!.topProducts
                    : calculator.topProductStats(
                        sales,
                        productLookup: productLookup,
                      ),
                currency: currency,
              ),
            );
            final promptPay = ReportStagger(
              index: stagger++,
              child: ReportPromptPayCard(
                sales: sales,
                currency: currency,
                fmt: fmt,
                calculator: calculator,
                aggregateLegTotal: aggregate?.promptPayLegTotal.value,
                aggregateBillCount: aggregate?.promptPayBillCount,
                aggregateRecentBills: aggregate?.recentPromptPaySales,
              ),
            );
            final closeDay = ReportStagger(
              index: stagger++,
              child: CloseDayCta(label: closeLabel, onPressed: onCloseDay),
            );

            if (constraints.maxWidth < 840) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  payment,
                  const SizedBox(height: 16),
                  topProducts,
                  const SizedBox(height: 16),
                  promptPay,
                  const SizedBox(height: 24),
                  closeDay,
                  const SizedBox(height: 4),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [payment, const SizedBox(height: 16), promptPay],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      topProducts,
                      const SizedBox(height: 16),
                      closeDay,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (tableBreakdown.isNotEmpty)
          ReportStagger(
            index: stagger++,
            child: ReportTableBreakdownCard(
              stats: tableBreakdown,
              currency: currency,
            ),
          ),
        const SizedBox(height: 16),
        ReportStagger(
          index: stagger++,
          child: ReportOrderBreakdownCard(totals: totals, currency: currency),
        ),
      ],
    );
  }
}
