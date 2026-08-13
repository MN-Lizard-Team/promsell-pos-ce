import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.currency,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.previousValue,

    /// Larger type + padding for primary net-revenue glance.
    this.emphasize = false,
  });

  final String title;
  final double value;
  final String currency;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double? previousValue;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reportTheme =
        theme.extension<ReportThemeExtension>() ?? ReportThemeExtension.light;
    final valueStyle = emphasize
        ? theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.15,
          )
        : theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold);
    final titleStyle = emphasize
        ? theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: scheme.onSurfaceVariant,
          )
        : theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    final spokenValue = CurrencyFormatter.formatGroupedWithSymbol(
      value,
      currency,
    );

    return Semantics(
      container: true,
      label: '$title, $spokenValue, $subtitle',
      child: Card(
        elevation: emphasize ? 2 : 0.5,
        shadowColor: color.withValues(alpha: 0.18),
        surfaceTintColor: emphasize ? color.withValues(alpha: 0.12) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            emphasize ? reportTheme.cardRadius + 4 : reportTheme.cardRadius,
          ),
          side: BorderSide(
            color: emphasize
                ? color.withValues(alpha: 0.22)
                : scheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(emphasize ? 20 : 16),
          child: Row(
            children: [
              Container(
                width: emphasize ? 56 : 44,
                height: emphasize ? 56 : 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    emphasize
                        ? reportTheme.controlRadius + 4
                        : reportTheme.controlRadius,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: emphasize
                      ? reportTheme.heroIconSize + 4
                      : reportTheme.heroIconSize,
                ),
              ),
              SizedBox(width: emphasize ? 18 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    SizedBox(height: emphasize ? 6 : 4),
                    MoneyText(
                      value: value,
                      currency: currency,
                      style: valueStyle,
                      color: color,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (previousValue != null) ...[
                      const SizedBox(height: 5),
                      _PeriodChange(
                        value: value,
                        previousValue: previousValue!,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodChange extends StatelessWidget {
  const _PeriodChange({required this.value, required this.previousValue});

  final double value;
  final double previousValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (previousValue == 0) return const SizedBox.shrink();
    final percent = ((value - previousValue) / previousValue) * 100;
    final isUp = percent > 0;
    final isFlat = percent.abs() < 0.05;
    final tone = isFlat
        ? scheme.onSurfaceVariant
        : (isUp ? scheme.primary : scheme.error);
    final icon = isFlat
        ? Icons.remove
        : (isUp ? Icons.trending_up : Icons.trending_down);
    final label = isFlat
        ? context.l10n.periodChangeZero
        : '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}% ${context.l10n.periodComparison}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: tone),
        const SizedBox(width: 4),
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
