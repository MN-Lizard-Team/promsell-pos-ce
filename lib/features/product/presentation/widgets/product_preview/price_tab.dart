import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class PriceTab extends StatelessWidget {
  const PriceTab({super.key, required this.product, required this.currency});

  final Product product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    // Unclamped so cost > price shows true loss (Money.- clamps at 0).
    final profit = product.price.subtractUnclamped(product.cost);
    final marginPct = product.price > Money.zero
        ? (profit.satang / product.price.satang) * 100
        : 0.0;
    final markupPct = product.cost > Money.zero
        ? (profit.satang / product.cost.satang) * 100
        : 0.0;
    final roiPct = markupPct;
    final totalRevenue = product.price * product.stock;
    final totalProfit = profit * product.stock;
    final dividerColor = theme.colorScheme.outlineVariant.withValues(
      alpha: 0.3,
    );
    final isDark = theme.brightness == Brightness.dark;
    final profitColor = !profit.isNegative
        ? (isDark ? AppColors.darkSuccess : AppColors.success)
        : theme.colorScheme.error;

    return ListView(
      padding: productPreviewTabPadding,
      children: [
        PreviewCard(
          title: l10n.tabPrice,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoListItem(
                icon: TablerIcons.tag,
                label: l10n.sellingPrice,
                value: MoneyText(
                  value: product.price.value,
                  currency: currency,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Divider(height: 1, color: dividerColor),
              InfoListItem(
                icon: TablerIcons.wallet,
                label: l10n.productPreviewCost,
                value: MoneyText(
                  value: product.cost.value,
                  currency: currency,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(height: 1, color: dividerColor),
              InfoListItem(
                icon: profit >= Money.zero
                    ? TablerIcons.trendingUp
                    : TablerIcons.trendingDown,
                label: l10n.profit,
                value: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MoneyText(
                      value: profit.value,
                      currency: currency,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: profitColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${marginPct.toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: profitColor,
                      ),
                    ),
                  ],
                ),
                valueColor: profitColor,
              ),
              Divider(height: 1, color: dividerColor),
              InfoListItem(
                icon: TablerIcons.percentage,
                label: l10n.productPreviewMarkup,
                value: Text(
                  '${markupPct.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: profitColor,
                  ),
                ),
                valueColor: profitColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PreviewCard(
          title: l10n.productPreviewRoi,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${roiPct.toStringAsFixed(0)}%',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: profitColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.productPreviewRoi,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (roiPct / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                  valueColor: AlwaysStoppedAnimation(profitColor),
                ),
              ),
            ],
          ),
        ),
        if (product.trackStock && product.stock > 0) ...[
          const SizedBox(height: 16),
          PreviewCard(
            title: l10n.productPreviewTotalRevenue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoListItem(
                  icon: TablerIcons.receipt,
                  label: l10n.productPreviewTotalRevenue,
                  value: MoneyText(
                    value: totalRevenue.value,
                    currency: currency,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Divider(height: 1, color: dividerColor),
                InfoListItem(
                  icon: TablerIcons.coin,
                  label: l10n.productPreviewTotalProfit,
                  value: MoneyText(
                    value: totalProfit.value,
                    currency: currency,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: profitColor,
                    ),
                  ),
                  valueColor: profitColor,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
