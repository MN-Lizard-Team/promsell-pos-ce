import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// A line chart showing daily revenue trend for the selected period.
///
/// Renders a [LineChart] from [DailyRevenue] data. When [dailyRevenue] is
/// empty, shows a compact empty-state placeholder.
class RevenueTrendChart extends StatelessWidget {
  const RevenueTrendChart({
    super.key,
    required this.dailyRevenue,
    required this.currency,
    this.height = 200,
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
    final spots = dailyRevenue
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.revenue))
        .toList();

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
      title: l10n.revenueTrend,
      icon: TablerIcons.chartLine,
      child: Semantics(
        label: '${l10n.revenueTrend}. $semanticsSummary',
        child: ExcludeSemantics(
          child: SizedBox(
            height: height,
            child: RepaintBoundary(
              child: LineChart(
                LineChartData(
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
                        interval: _calcInterval(dailyRevenue.length),
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
                  minX: 0,
                  maxX: (dailyRevenue.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                      getTooltipItems: (touchedSpots) => touchedSpots.map((
                        spot,
                      ) {
                        final i = spot.x.toInt();
                        if (i < 0 || i >= dailyRevenue.length) {
                          return null;
                        }
                        final d = dailyRevenue[i];
                        final amount =
                            CurrencyFormatter.formatGroupedWithSymbol(
                              spot.y,
                              currency,
                              locale: locale,
                            );
                        return LineTooltipItem(
                          '${dateFormat.format(d.date)}\n'
                          '$amount\n'
                          '${l10n.salesCount(d.count)}',
                          TextStyle(color: theme.colorScheme.onInverseSurface),
                        );
                      }).toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: theme.colorScheme.primary,
                              strokeWidth: 0,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _calcInterval(int days) {
    if (days <= 7) return 1;
    if (days <= 14) return 2;
    if (days <= 31) return 5;
    return 10;
  }
}
