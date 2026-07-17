import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';

class ProductFilterTabs extends StatelessWidget {
  const ProductFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.select<ProductBloc, ProductState>(
      (bloc) => bloc.state,
    );
    final productSort = state.productSort;
    final hasCategory = state.categoryFilter != null;
    final hasStock = state.stockFilter != StockFilter.all;
    final hasActiveFilter =
        state.searchQuery.isNotEmpty ||
        hasCategory ||
        hasStock ||
        state.productSort != ProductSort.default_ ||
        (state.priceRange?.isActive ?? false);

    final cs = theme.colorScheme;
    final categoryLabel = _categoryChipLabel(context, state);
    final categoryIcon = _categoryChipIcon(context, state);
    final stockLabel = _stockChipLabel(context, state);
    final stockIcon = switch (state.stockFilter) {
      StockFilter.lowStock => Icons.warning_amber_rounded,
      StockFilter.outOfStock => Icons.error_outline,
      StockFilter.all => Icons.inventory_2_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      // Chips scroll; clear stays pinned on the right so it is always findable.
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: l10n.productTabAll,
                    icon: Icons.grid_view_rounded,
                    // All = no category/stock filter (search may still be active).
                    selected: !hasCategory && !hasStock,
                    onTap: () => context.read<ProductBloc>().add(
                      const ProductTabChanged(ProductTabFilter.all),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: categoryLabel,
                    icon: categoryIcon,
                    selected: hasCategory,
                    maxLabelWidth: 120,
                    onClear: hasCategory
                        ? () {
                            final bloc = context.read<ProductBloc>();
                            bloc.add(const ProductCategoryFilterChanged(null));
                            if (!hasStock) {
                              bloc.add(
                                const ProductTabChanged(ProductTabFilter.all),
                              );
                            }
                          }
                        : null,
                    onTap: () =>
                        _showCategoryBottomSheet(context, state, theme),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: stockLabel,
                    icon: stockIcon,
                    selected: hasStock,
                    onClear: hasStock
                        ? () {
                            final bloc = context.read<ProductBloc>();
                            bloc.add(
                              const ProductStockFilterChanged(StockFilter.all),
                            );
                            if (!hasCategory) {
                              bloc.add(
                                const ProductTabChanged(ProductTabFilter.all),
                              );
                            }
                          }
                        : null,
                    onTap: () => _showStockBottomSheet(context, state, theme),
                  ),
                  const SizedBox(width: 4),
                  Badge(
                    isLabelVisible: productSort != ProductSort.default_,
                    smallSize: 8,
                    child: IconButton(
                      icon: Icon(Icons.tune, color: cs.onSurfaceVariant),
                      tooltip: l10n.filterSort,
                      onPressed: () =>
                          _showSortBottomSheet(context, productSort, theme),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Compact clear control (small X), pinned so it never scrolls away.
          if (hasActiveFilter)
            IconButton(
              key: const ValueKey('product-list-clear-filters'),
              tooltip: l10n.clearFilters,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
              iconSize: 18,
              icon: Icon(Icons.close, color: cs.onSurfaceVariant),
              onPressed: () {
                context.read<ProductBloc>().add(const ProductFiltersCleared());
              },
            ),
        ],
      ),
    );
  }

  String _categoryChipLabel(BuildContext context, ProductState state) {
    final l10n = context.l10n;
    final id = state.categoryFilter;
    if (id == null) return l10n.productTabCategory;
    if (id == kNoCategoryFilter) return l10n.noCategory;
    final categories = context.read<CategoryBloc>().state.categories;
    for (final cat in categories) {
      if (cat.id == id) return cat.name;
    }
    return l10n.productTabCategory;
  }

  IconData _categoryChipIcon(BuildContext context, ProductState state) {
    final id = state.categoryFilter;
    if (id == null || id == kNoCategoryFilter) {
      return Icons.category_rounded;
    }
    final categories = context.read<CategoryBloc>().state.categories;
    for (final cat in categories) {
      if (cat.id == id) return parseCategoryIcon(cat.iconName);
    }
    return Icons.category_rounded;
  }

  String _stockChipLabel(BuildContext context, ProductState state) {
    final l10n = context.l10n;
    return switch (state.stockFilter) {
      StockFilter.lowStock => l10n.lowStock,
      StockFilter.outOfStock => l10n.outOfStock,
      StockFilter.all => l10n.productTabStock,
    };
  }

  void _showCategoryBottomSheet(
    BuildContext context,
    ProductState state,
    ThemeData theme,
  ) {
    final l10n = context.l10n;
    final categoryState = context.read<CategoryBloc>().state;
    final categories = categoryState.categories;

    // Do not emit ProductTabChanged on open — that clears stock filter.
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.productTabCategory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                state.categoryFilter == null
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: state.categoryFilter == null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(l10n.allCategories),
              onTap: () {
                final bloc = context.read<ProductBloc>();
                bloc.add(const ProductCategoryFilterChanged(null));
                bloc.add(const ProductTabChanged(ProductTabFilter.all));
                Navigator.pop(ctx);
              },
            ),
            ...categories.map((cat) {
              final isSelected = state.categoryFilter == cat.id;
              final color = parseCategoryColor(cat.color);
              final icon = parseCategoryIcon(cat.iconName);
              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 16, color: color),
                    ),
                  ],
                ),
                title: Text(cat.name),
                onTap: () {
                  final bloc = context.read<ProductBloc>();
                  bloc.add(ProductCategoryFilterChanged(cat.id));
                  // Apply tab after selection only (does not clear stock).
                  bloc.add(const ProductTabChanged(ProductTabFilter.category));
                  Navigator.pop(ctx);
                },
              );
            }),
            ListTile(
              leading: Icon(
                state.categoryFilter == kNoCategoryFilter
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: state.categoryFilter == kNoCategoryFilter
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(l10n.noCategory),
              onTap: () {
                final bloc = context.read<ProductBloc>();
                bloc.add(const ProductCategoryFilterChanged(kNoCategoryFilter));
                bloc.add(const ProductTabChanged(ProductTabFilter.category));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStockBottomSheet(
    BuildContext context,
    ProductState state,
    ThemeData theme,
  ) {
    final l10n = context.l10n;

    // Do not emit ProductTabChanged on open — that clears category filter.
    final options = [
      (StockFilter.all, l10n.productTabAll, null),
      (StockFilter.lowStock, l10n.lowStock, Icons.warning_amber),
      (StockFilter.outOfStock, l10n.outOfStock, Icons.error_outline),
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.productTabStock,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ...options.map((option) {
              final isSelected = state.stockFilter == option.$1;
              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 20,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    if (option.$3 != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        option.$3,
                        size: 20,
                        color: option.$1 == StockFilter.outOfStock
                            ? theme.colorScheme.error
                            : theme.colorScheme.tertiary,
                      ),
                    ],
                  ],
                ),
                title: Text(option.$2),
                onTap: () {
                  final bloc = context.read<ProductBloc>();
                  bloc.add(ProductStockFilterChanged(option.$1));
                  if (option.$1 == StockFilter.all) {
                    bloc.add(const ProductTabChanged(ProductTabFilter.all));
                  } else {
                    bloc.add(const ProductTabChanged(ProductTabFilter.stock));
                  }
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(
    BuildContext context,
    ProductSort currentSort,
    ThemeData theme,
  ) {
    final l10n = context.l10n;
    final options = [
      (ProductSort.default_, l10n.sortDefault),
      (ProductSort.nameAsc, l10n.sortNameAsc),
      (ProductSort.priceLowHigh, l10n.sortPriceLowHigh),
      (ProductSort.priceHighLow, l10n.sortPriceHighLow),
      (ProductSort.stockLowHigh, l10n.sortStockLowHigh),
    ];

    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.filterSort,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            ...options.map((option) {
              final isSelected = option.$1 == currentSort;
              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(option.$2),
                onTap: () {
                  context.read<ProductBloc>().add(
                    ProductSortChanged(option.$1),
                  );
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.onClear,
    this.maxLabelWidth,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final VoidCallback? onClear;
  final double? maxLabelWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onColor = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.horizontal(
                left: const Radius.circular(24),
                right: Radius.circular(onClear != null ? 0 : 24),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14,
                  right: onClear != null ? 4 : 14,
                  top: 8,
                  bottom: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: onColor),
                      const SizedBox(width: 6),
                    ],
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: maxLabelWidth ?? 160,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: onColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onClear != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClear,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 2,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Icon(Icons.close, size: 14, color: onColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
