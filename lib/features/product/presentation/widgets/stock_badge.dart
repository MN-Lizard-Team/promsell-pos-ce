import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color color;
    if (stock == 0) {
      color = theme.colorScheme.error;
    } else if (stock <= 5) {
      color = theme.colorScheme.tertiary;
    } else {
      color = theme.colorScheme.primary;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          context.l10n.stockLabel(stock),
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
