import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class StockIndicator extends StatelessWidget {
  const StockIndicator({
    super.key,
    required this.stock,
    this.trackStock = true,
    this.compact = false,
  });

  final int stock;
  final bool trackStock;
  final bool compact;

  ({Color color, IconData icon, String label}) _resolve(BuildContext context) {
    final l10n = context.l10n;
    if (!trackStock) {
      return (
        color: Theme.of(context).colorScheme.outline,
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
    if (stock <= 5) {
      return (
        color: Theme.of(context).colorScheme.tertiary,
        icon: Icons.warning,
        label: stock.toString(),
      );
    }
    return (
      color: Theme.of(context).colorScheme.primary,
      icon: Icons.check_circle,
      label: stock.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolved = _resolve(context);

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolved.icon, size: 14, color: resolved.color),
          const SizedBox(width: 4),
          Text(
            resolved.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: resolved.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
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
            resolved.label,
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
