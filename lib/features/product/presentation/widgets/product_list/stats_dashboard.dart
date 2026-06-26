import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';

class StatsDashboard extends StatelessWidget {
  const StatsDashboard({
    super.key,
    required this.activeCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalCount,
    required this.inventoryValue,
    required this.currency,
    required this.activeFilter,
    required this.onFilterTap,
  });

  final int activeCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int totalCount;
  final double inventoryValue;
  final String currency;
  final StockFilter activeFilter;
  final ValueChanged<StockFilter> onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      children: [
        _HeroStatCard(
          totalCount: totalCount,
          inventoryValue: inventoryValue,
          currency: currency,
          totalLabel: l10n.totalProducts,
          valueLabel: l10n.inventoryValue,
          gradientStart: theme.colorScheme.primary,
          gradientEnd: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: Icons.check_circle_outline,
                label: '$activeCount',
                subtitle: l10n.productsCount,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.warning_amber_rounded,
                label: '$lowStockCount',
                subtitle: l10n.lowStock,
                color: theme.colorScheme.tertiary,
                dimmed: lowStockCount == 0,
                isSelected: activeFilter == StockFilter.lowStock,
                onTap: lowStockCount > 0
                    ? () => onFilterTap(StockFilter.lowStock)
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.error_outline,
                label: '$outOfStockCount',
                subtitle: l10n.outOfStock,
                color: theme.colorScheme.error,
                dimmed: outOfStockCount == 0,
                isSelected: activeFilter == StockFilter.outOfStock,
                onTap: outOfStockCount > 0
                    ? () => onFilterTap(StockFilter.outOfStock)
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.totalCount,
    required this.inventoryValue,
    required this.currency,
    required this.totalLabel,
    required this.valueLabel,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final int totalCount;
  final double inventoryValue;
  final String currency;
  final String totalLabel;
  final String valueLabel;
  final Color gradientStart;
  final Color gradientEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalCount',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  totalLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$currency${inventoryValue.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valueLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.dimmed = false,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool dimmed;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = dimmed ? theme.colorScheme.outline : color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: effectiveColor, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: effectiveColor),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: effectiveColor,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
