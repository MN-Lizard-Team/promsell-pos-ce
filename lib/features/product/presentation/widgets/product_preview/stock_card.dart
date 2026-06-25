import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/shared_widgets.dart';

class StockCard extends StatelessWidget {
  const StockCard({
    super.key,
    required this.product,
    required this.currency,
    this.onEditStock,
  });

  final Product product;
  final String currency;
  final VoidCallback? onEditStock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final iconBgAlpha = isDark ? 0.20 : 0.12;
    final badgeBgAlpha = isDark ? 0.25 : 0.15;
    final stockInfo = _resolveStock(context);
    final stockValue = product.stock * product.cost;

    return PreviewCard(
      icon: Icons.inventory_2_outlined,
      title: l10n.tabStock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.trackStock)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: stockInfo.color.withValues(alpha: iconBgAlpha),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(stockInfo.icon, size: 28, color: stockInfo.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            product.stock.toString(),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.quantityLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: stockInfo.color.withValues(
                            alpha: badgeBgAlpha,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          stockInfo.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: stockInfo.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  Icons.remove_circle_outline,
                  size: 20,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.disabled,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          if (product.trackStock && product.cost > 0) ...[
            const SizedBox(height: 12),
            InfoRow(
              label: l10n.productPreviewStockValue,
              value: MoneyText(
                value: stockValue,
                currency: currency,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
          if (product.trackStock && onEditStock != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onEditStock,
              icon: const Icon(Icons.edit, size: 16),
              label: Text(l10n.edit),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ({Color color, IconData icon, String label}) _resolveStock(
    BuildContext context,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    if (product.stock == 0) {
      return (
        color: isDark ? const Color(0xFFF87171) : theme.colorScheme.error,
        icon: Icons.error,
        label: l10n.outOfStock,
      );
    }
    if (product.stock <= 5) {
      return (
        color: isDark ? const Color(0xFFFB923C) : theme.colorScheme.tertiary,
        icon: Icons.warning,
        label: l10n.lowStock,
      );
    }
    return (
      color: isDark ? const Color(0xFF2DD4BF) : theme.colorScheme.primary,
      icon: Icons.check_circle,
      label: l10n.inStock,
    );
  }
}
