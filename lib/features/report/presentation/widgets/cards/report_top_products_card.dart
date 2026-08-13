import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/top_product_stat.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class ReportTopProductsCard extends StatelessWidget {
  const ReportTopProductsCard({
    super.key,
    required this.topProducts,
    required this.currency,
  });

  final List<TopProductStat> topProducts;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ReportSectionCard(
      title: context.l10n.topProducts,
      icon: TablerIcons.trendingUp,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: topProducts.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                context.l10n.noSalesYet,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                for (final entry in topProducts.asMap().entries)
                  _TopProductRow(
                    key: ValueKey('top-product-${entry.key}'),
                    rank: entry.key + 1,
                    product: entry.value,
                    currency: currency,
                  ),
              ],
            ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  const _TopProductRow({
    super.key,
    required this.rank,
    required this.product,
    required this.currency,
  });

  final int rank;
  final TopProductStat product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isTop = rank == 1;

    return Semantics(
      container: true,
      label:
          '${context.l10n.topProducts} $rank: ${product.displayName}, ${context.l10n.units(product.qty)}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTop ? scheme.primary : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$rank',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isTop ? scheme.onPrimary : scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                product.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isTop ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.l10n.units(product.qty),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MoneyText(
                  value: product.revenue,
                  currency: currency,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (product.hasCostData && product.marginPercent != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${product.marginPercent!.toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: product.marginPercent! >= 0
                          ? scheme.primary
                          : scheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
