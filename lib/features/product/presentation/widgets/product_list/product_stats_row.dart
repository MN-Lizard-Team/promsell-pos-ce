import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class ProductStatsRow extends StatelessWidget {
  const ProductStatsRow({
    super.key,
    required this.activeCount,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalCount,
    required this.inventoryValue,
    required this.currency,
    required this.activeFilter,
    required this.onFilterTap,
    this.isLoading = false,
  });

  final int activeCount;
  final int lowStockCount;
  final int outOfStockCount;
  final int totalCount;
  final double inventoryValue;
  final String currency;
  final StockFilter activeFilter;
  final ValueChanged<StockFilter> onFilterTap;
  final bool isLoading;

  static String _currencyName(String symbol, AppLocalizations l10n) {
    switch (symbol) {
      case '฿':
        return l10n.currencyBaht;
      case '\$':
        return l10n.currencyDollar;
      case '€':
        return l10n.currencyEuro;
      case '¥':
        return l10n.currencyYen;
      default:
        return symbol;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.inventory_outlined,
              value: '$totalCount',
              label: l10n.totalProducts,
              unit: l10n.itemsLabel,
              color: cs.primary,
              isLoading: isLoading,
              isSelected: activeFilter == StockFilter.all,
              onTap: () => onFilterTap(StockFilter.all),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _StatCard(
              icon: Icons.trending_down_rounded,
              value: '$lowStockCount',
              label: l10n.lowStock,
              unit: l10n.itemsLabel,
              color: cs.tertiary,
              isLoading: isLoading,
              dimmed: lowStockCount == 0,
              isSelected: activeFilter == StockFilter.lowStock,
              onTap: () => onFilterTap(StockFilter.lowStock),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _StatCard(
              icon: Icons.cancel_rounded,
              value: '$outOfStockCount',
              label: l10n.outOfStock,
              unit: l10n.itemsLabel,
              color: cs.error,
              isLoading: isLoading,
              dimmed: outOfStockCount == 0,
              isSelected: activeFilter == StockFilter.outOfStock,
              onTap: () => onFilterTap(StockFilter.outOfStock),
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _StatCard(
              icon: Icons.savings_outlined,
              value: CurrencyFormatter.formatCompactWithSymbol(
                inventoryValue,
                currency,
              ),
              label: l10n.inventoryValue,
              unit: _currencyName(currency, l10n),
              color: cs.primary,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.unit,
    this.dimmed = false,
    this.isSelected = false,
    this.isLoading = false,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? unit;
  final bool dimmed;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final iconColor = color;

    return Semantics(
      label: '$label $value',
      button: onTap != null,
      child: Card(
        elevation: isSelected ? 8 : 4,
        shadowColor: cs.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Shimmer.fromColors(
                      baseColor: cs.surfaceContainerHighest,
                      highlightColor: cs.surfaceContainerLow,
                      child: Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: color,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (unit != null)
                      Flexible(
                        child: Text(
                          unit!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else
                      const Spacer(),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 22, color: iconColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
