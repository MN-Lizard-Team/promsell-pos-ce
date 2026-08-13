import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Profit & margin analytics card: gross profit, total cost, margin % with
/// period-over-period delta, and cost-coverage bar when data is incomplete.
class ReportProfitabilityCard extends StatelessWidget {
  const ReportProfitabilityCard({
    super.key,
    required this.profit,
    this.previousProfit,
    required this.currency,
  });

  final ProfitAnalytics profit;
  final ProfitAnalytics? previousProfit;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (profit.hasNoCoverage) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final marginColor = profit.marginPercent >= 0
        ? scheme.primary
        : scheme.error;

    final prevMargin = previousProfit?.marginPercent;
    final hasMarginComparison =
        previousProfit != null &&
        !previousProfit!.hasNoCoverage &&
        prevMargin != null;

    return ReportSectionCard(
      title: l10n.profitability,
      icon: TablerIcons.chartPie,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Metric(
                label: l10n.grossProfit,
                value: profit.grossProfit.value,
                currency: currency,
                color: marginColor,
              ),
              _Metric(
                label: l10n.totalCost,
                value: profit.totalCost.value,
                currency: currency,
                color: scheme.onSurfaceVariant,
              ),
              _MarginMetric(
                label: l10n.profitMargin,
                value: profit.marginPercent,
                color: marginColor,
                previousValue: hasMarginComparison ? prevMargin : null,
              ),
            ],
          ),
          if (!profit.hasFullCoverage) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  TablerIcons.infoCircle,
                  size: 14,
                  color: scheme.tertiary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.costCoverageIncomplete(
                      profit.totalItems,
                      profit.itemsWithCost,
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: profit.coveragePercent,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(scheme.tertiary),
              ),
            ),
          ],
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

class _MarginMetric extends StatelessWidget {
  const _MarginMetric({
    required this.label,
    required this.value,
    required this.color,
    this.previousValue,
  });

  final String label;
  final double value;
  final Color color;
  final double? previousValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: ${value.toStringAsFixed(1)}%',
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
              '${value.toStringAsFixed(1)}%',
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (previousValue != null) ...[
              const SizedBox(height: 2),
              _MarginDelta(current: value, previous: previousValue!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MarginDelta extends StatelessWidget {
  const _MarginDelta({required this.current, required this.previous});

  final double current;
  final double previous;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final delta = current - previous;
    final isFlat = delta.abs() < 0.05;
    final tone = isFlat
        ? scheme.onSurfaceVariant
        : (delta > 0 ? scheme.primary : scheme.error);
    final icon = isFlat
        ? Icons.remove
        : (delta > 0 ? Icons.trending_up : Icons.trending_down);
    final pp = l10n.percentagePointsUnit;
    final label = isFlat
        ? '0.0$pp'
        : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}$pp';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: tone),
        const SizedBox(width: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: tone,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
