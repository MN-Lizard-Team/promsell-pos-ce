import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Compact secondary-metric strip shown beneath the hero Net Revenue card.
///
/// Surfaces voided total, VAT collected, and discount as small stat chips so
/// they no longer compete with the hero card. Chips that are zero are omitted
/// to keep the row scannable.
class ReportQuickStatsStrip extends StatelessWidget {
  const ReportQuickStatsStrip({
    super.key,
    required this.totals,
    required this.currency,
    this.profit,
  });

  final SalesPeriodTotals totals;
  final String currency;
  final ProfitAnalytics? profit;

  @override
  Widget build(BuildContext context) {
    final profitData = profit;
    final scheme = Theme.of(context).colorScheme;
    final items = <_StatChipData>[
      if (totals.voidCount > 0)
        _StatChipData(
          icon: TablerIcons.ban,
          label: context.l10n.voidedTotal,
          value: totals.voidedTotal.value,
          currency: currency,
          color: scheme.error,
        ),
      if (totals.vatAmount.value > 0)
        _StatChipData(
          icon: TablerIcons.receiptTax,
          label: context.l10n.dailyCloseVatCollected,
          value: totals.vatAmount.value,
          currency: currency,
          color: scheme.tertiary,
        ),
      if (totals.discountAmount.value > 0)
        _StatChipData(
          icon: TablerIcons.tag,
          label: context.l10n.discountSectionLabel,
          value: totals.discountAmount.value,
          currency: currency,
          color: scheme.secondary,
        ),
      if (profitData != null &&
          !profitData.hasNoCoverage &&
          profitData.grossProfit.value != 0)
        _StatChipData(
          icon: TablerIcons.chartPie,
          label: context.l10n.grossProfit,
          value: profitData.grossProfit.value,
          currency: currency,
          color: profitData.marginPercent >= 0 ? scheme.primary : scheme.error,
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    final reportTheme =
        Theme.of(context).extension<ReportThemeExtension>() ??
        ReportThemeExtension.light;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final item in items)
            _StatChip(data: item, controlRadius: reportTheme.controlRadius),
        ],
      ),
    );
  }
}

class _StatChipData {
  const _StatChipData({
    required this.icon,
    required this.label,
    required this.value,
    required this.currency,
    required this.color,
  });

  final IconData icon;
  final String label;
  final double value;
  final String currency;
  final Color color;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.data, required this.controlRadius});

  final _StatChipData data;
  final double controlRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spoken = CurrencyFormatter.formatGroupedWithSymbol(
      data.value,
      data.currency,
    );
    return Semantics(
      label: '${data.label}, $spoken',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(controlRadius),
          border: Border.all(color: data.color.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, size: 18, color: data.color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MoneyText(
                  value: data.value,
                  currency: data.currency,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: data.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
