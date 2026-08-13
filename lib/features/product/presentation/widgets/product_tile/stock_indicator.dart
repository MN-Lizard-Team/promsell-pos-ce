import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';

class StockIndicator extends StatelessWidget {
  const StockIndicator({
    super.key,
    required this.stock,
    this.trackStock = true,
    this.compact = false,
    this.lowStockThreshold = 5,
    this.showStockLabel = false,
  });

  final int stock;
  final bool trackStock;
  final bool compact;
  final int lowStockThreshold;
  final bool showStockLabel;

  ({Color color, IconData icon, String label}) _resolve(BuildContext context) {
    final l10n = context.l10n;
    final threshold = lowStockThreshold < 1 ? 1 : lowStockThreshold;
    final qtyLabel = CurrencyFormatter.formatQuantityCompact(stock);
    if (!trackStock) {
      return (
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        icon: Icons.remove_circle_outline,
        label: l10n.na,
      );
    }
    if (stock == 0) {
      return (
        color: Theme.of(context).colorScheme.error,
        icon: Icons.error,
        label: l10n.outOfStockShort,
      );
    }
    if (stock <= threshold) {
      return (
        color: Theme.of(context).colorScheme.tertiary,
        icon: Icons.warning,
        label: qtyLabel,
      );
    }
    return (
      color: Theme.of(context).colorScheme.primary,
      icon: Icons.check_circle,
      label: qtyLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = _resolve(context);
    final label = showStockLabel && trackStock && stock > 0
        ? '${context.l10n.stockOnHand} ${resolved.label}'
        : resolved.label;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolved.icon, size: 10, color: resolved.color),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: resolved.color,
                fontWeight: FontWeight.w600,
                fontSize: 9,
                height: 1.0,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: resolved.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolved.icon, size: 14, color: resolved.color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: resolved.color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
