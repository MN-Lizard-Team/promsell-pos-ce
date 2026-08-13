import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// A bar chart showing daily revenue breakdown for the selected period.
///
/// Renders a [BarChart] from [DailyRevenue] data. Tapping a bar shows
/// a tooltip with the exact revenue and transaction count.
class DailyRevenueBarChart extends StatelessWidget {
  const DailyRevenueBarChart({
    super.key,
    required this.dailyRevenue,
    required this.currency,
    this.height = 180,
  });

  final List<DailyRevenue> dailyRevenue;
  final String currency;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (dailyRevenue.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateFormat = DateFormat.Md(locale);
    final rawMaxY = dailyRevenue
        .map((d) => d.revenue)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = rawMaxY > 0 ? rawMaxY * 1.2 : 1.0;

    final semanticsSummary = dailyRevenue
        .map((d) {
          final amount = CurrencyFormatter.formatGroupedWithSymbol(
            d.revenue,
            currency,
            locale: locale,
          );
          return '${dateFormat.format(d.date)}: $amount, ${l10n.salesCount(d.count)}';
        })
        .join('. ');

    return ReportSectionCard(
      title: l10n.dailyRevenue,
      icon: TablerIcons.chartBar,
      child: Semantics(
        label: '${l10n.dailyRevenue}. $semanticsSummary',
        child: ExcludeSemantics(
          child: SizedBox(
            height: height,
            child: RepaintBoundary(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= dailyRevenue.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              dateFormat.format(dailyRevenue[i].date),
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final d = dailyRevenue[group.x];
                        final amount =
                            CurrencyFormatter.formatGroupedWithSymbol(
                              rod.toY,
                              currency,
                              locale: locale,
                            );
                        return BarTooltipItem(
                          '${dateFormat.format(d.date)}\n'
                          '$amount\n'
                          '${l10n.salesCount(d.count)}',
                          TextStyle(color: theme.colorScheme.onInverseSurface),
                        );
                      },
                    ),
                  ),
                  barGroups: dailyRevenue.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.revenue,
                          color: theme.colorScheme.primary,
                          width: _barWidth(dailyRevenue.length),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _barWidth(int days) {
    if (days <= 7) return 24;
    if (days <= 14) return 16;
    if (days <= 31) return 10;
    return 6;
  }
}
