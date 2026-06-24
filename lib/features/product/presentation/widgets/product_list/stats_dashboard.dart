import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';

class StatsDashboard extends StatelessWidget {
  const StatsDashboard({
    super.key,
    required this.products,
    required this.activeFilter,
    required this.onFilterTap,
  });

  final List<Product> products;
  final StockFilter activeFilter;
  final ValueChanged<StockFilter> onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = products.where((p) => p.isActive).length;
    final lowStock = products
        .where((p) => p.trackStock && p.stock > 0 && p.stock <= 5)
        .length;
    final outOfStock = products
        .where((p) => p.trackStock && p.stock == 0)
        .length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.inventory_2,
            label: '$active',
            subtitle: context.l10n.productsCount,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: StatCard(
            icon: Icons.warning_amber_rounded,
            label: '$lowStock',
            subtitle: context.l10n.lowStock,
            color: theme.colorScheme.tertiary,
            dimmed: lowStock == 0,
            isSelected: activeFilter == StockFilter.lowStock,
            onTap: lowStock > 0
                ? () => onFilterTap(StockFilter.lowStock)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: StatCard(
            icon: Icons.error_outline,
            label: '$outOfStock',
            subtitle: context.l10n.outOfStock,
            color: theme.colorScheme.error,
            dimmed: outOfStock == 0,
            isSelected: activeFilter == StockFilter.outOfStock,
            onTap: outOfStock > 0
                ? () => onFilterTap(StockFilter.outOfStock)
                : null,
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
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
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: effectiveColor, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: effectiveColor),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: effectiveColor,
                        fontSize: 15,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
