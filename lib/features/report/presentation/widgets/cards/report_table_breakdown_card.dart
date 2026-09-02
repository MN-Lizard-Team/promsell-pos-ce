import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/table_sales_stat.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/services/restaurant_table_name_resolver.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class ReportTableBreakdownCard extends StatelessWidget {
  const ReportTableBreakdownCard({
    super.key,
    required this.stats,
    required this.currency,
  });

  final List<TableSalesStat> stats;
  final String currency;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    final maxRevenue = stats.fold<int>(
      0,
      (max, item) => item.revenueSatang > max ? item.revenueSatang : max,
    );
    return ReportSectionCard(
      title: context.l10n.tableSalesBreakdown,
      icon: TablerIcons.layoutGrid,
      child: Column(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _TableRow(
              stat: stats[i],
              maxRevenueSatang: maxRevenue,
              currency: currency,
            ),
          ],
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.stat,
    required this.maxRevenueSatang,
    required this.currency,
  });

  final TableSalesStat stat;
  final int maxRevenueSatang;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = maxRevenueSatang == 0
        ? 0.0
        : (stat.revenueSatang / maxRevenueSatang).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _TableName(stat: stat)),
            MoneyText(
              value: stat.revenue,
              currency: currency,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: ratio,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(scheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.salesCount(stat.orderCount),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _TableName extends StatelessWidget {
  const _TableName({required this.stat});

  final TableSalesStat stat;

  @override
  Widget build(BuildContext context) {
    if (stat.isNoTable) return Text(context.l10n.noTable);
    return FutureBuilder<String?>(
      future: sl<RestaurantTableNameResolver>().resolve(stat.tableId),
      builder: (context, snapshot) {
        final name = snapshot.data ?? stat.tableId;
        return Text(
          context.l10n.tableChipLabel(name),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
