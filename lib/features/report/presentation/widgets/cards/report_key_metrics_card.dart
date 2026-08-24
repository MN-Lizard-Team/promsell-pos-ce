import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sales_period_totals.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Key analytical metrics: gross revenue, ATV, peak hour, customers, promo orders.
class ReportKeyMetricsCard extends StatelessWidget {
  const ReportKeyMetricsCard({
    super.key,
    required this.totals,
    required this.sales,
    required this.currency,
    required this.calculator,
  });

  final SalesPeriodTotals totals;
  final List<Sale> sales;
  final String currency;
  final ReportCalculatorService calculator;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hourly = calculator.hourlyRevenue(sales);
    final peak = hourly.entries.isEmpty
        ? null
        : (hourly.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
              .first;
    final uniqueCustomers = calculator.uniqueCustomerCount(sales);
    final repeatCustomers = calculator.repeatCustomerCount(sales);

    final hasContent =
        totals.grossRevenue.value > 0 ||
        totals.averageTransactionValue.value > 0 ||
        peak != null ||
        uniqueCustomers > 0 ||
        totals.promotionCount > 0;
    if (!hasContent) return const SizedBox.shrink();

    return ReportSectionCard(
      title: context.l10n.insights,
      icon: TablerIcons.chartDots3,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _Metric(
            label: context.l10n.grossRevenue,
            value: totals.grossRevenue.value,
            currency: currency,
            color: scheme.primary,
          ),
          _Metric(
            label: context.l10n.averageTransactionValue,
            value: totals.averageTransactionValue.value,
            currency: currency,
            color: scheme.secondary,
          ),
          if (peak != null)
            _Metric(
              label: '${context.l10n.peakHours} ${peak.key}:00',
              value: peak.value,
              currency: currency,
              color: scheme.tertiary,
            ),
          if (uniqueCustomers > 0)
            _CountMetric(
              label: context.l10n.uniqueCustomers,
              value: uniqueCustomers,
              color: scheme.primary,
            ),
          if (repeatCustomers > 0)
            _CountMetric(
              label: context.l10n.repeatCustomers,
              value: repeatCustomers,
              color: scheme.secondary,
            ),
          if (totals.promotionCount > 0)
            _CountMetric(
              label: context.l10n.promotionOrders,
              value: totals.promotionCount,
              color: scheme.tertiary,
            ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.currency,
    required this.color,
  });

  final String label;
  final double value;
  final String currency;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: ${value.toStringAsFixed(2)} $currency',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 2),
            MoneyText(
              value: value,
              currency: currency,
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountMetric extends StatelessWidget {
  const _CountMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 2),
            Text(
              '$value',
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
