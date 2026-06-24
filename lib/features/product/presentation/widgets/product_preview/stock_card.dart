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
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: stockInfo.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        product.stock.toString(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: stockInfo.color,
                          fontSize: 26,
                        ),
                      ),
                      Text(
                        l10n.quantityLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: stockInfo.color.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            stockInfo.icon,
                            size: 16,
                            color: stockInfo.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stockInfo.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: stockInfo.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      InfoRow(
                        label: l10n.productPreviewStockValue,
                        value: MoneyText(
                          value: stockValue,
                          currency: currency,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (onEditStock != null)
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
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.disabled,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  ({Color color, IconData icon, String label}) _resolveStock(
    BuildContext context,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (product.stock == 0) {
      return (
        color: theme.colorScheme.error,
        icon: Icons.error,
        label: l10n.outOfStock,
      );
    }
    if (product.stock <= 5) {
      return (
        color: theme.colorScheme.tertiary,
        icon: Icons.warning,
        label: l10n.lowStock,
      );
    }
    return (
      color: theme.colorScheme.primary,
      icon: Icons.check_circle,
      label: l10n.lowStockWarning,
    );
  }
}
