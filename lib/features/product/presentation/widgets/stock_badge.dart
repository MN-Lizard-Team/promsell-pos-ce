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

    final IconData icon;
    if (stock == 0) {
      icon = Icons.error_outline;
    } else if (stock <= 5) {
      icon = Icons.warning_amber;
    } else {
      icon = Icons.check_circle_outline;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              context.l10n.stockLabel(stock),
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
