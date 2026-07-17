import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/category_filter_chips.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_filter_bar.dart';

/// Unified Sale catalog filter chrome: categories + tools in one card.
class SaleCatalogFilterChrome extends StatelessWidget {
  const SaleCatalogFilterChrome({
    super.key,
    required this.categories,
    required this.productState,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onCategorySelected,
    required this.recommendedOnly,
    required this.hasRecommended,
    required this.onRecommendedChanged,
    this.showCategories = true,
  });

  final List<Category> categories;
  final ProductState productState;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final ValueChanged<String?> onCategorySelected;
  final bool recommendedOnly;
  final bool hasRecommended;
  final ValueChanged<bool> onRecommendedChanged;
  final bool showCategories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    // Wireframe: "Tab Category" left, "Filter" right, chips below.
    return Material(
      color: theme.colorScheme.surface,
      elevation: 0.5,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCategories)
              Row(
                children: [
                  Text(
                    l10n.saleCategoryTabsLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (hasRecommended) ...[
                    _RecommendedToggle(
                      selected: recommendedOnly,
                      label: l10n.saleRecommendedFilter,
                      onChanged: onRecommendedChanged,
                      compact: true,
                    ),
                    const SizedBox(width: 4),
                  ],
                  // compact avoids Expanded-in-unbounded-Row from PillButton.
                  SaleFilterBar(productState: productState, compact: true),
                  const SizedBox(width: 4),
                  _ViewModeToggle(
                    viewMode: viewMode,
                    onChanged: onViewModeChanged,
                  ),
                ],
              )
            else
              Row(
                children: [
                  if (hasRecommended) ...[
                    _RecommendedToggle(
                      selected: recommendedOnly,
                      label: l10n.saleRecommendedFilter,
                      onChanged: onRecommendedChanged,
                      compact: true,
                    ),
                    const SizedBox(width: 4),
                  ],
                  SaleFilterBar(productState: productState, compact: true),
                  const SizedBox(width: 4),
                  _ViewModeToggle(
                    viewMode: viewMode,
                    onChanged: onViewModeChanged,
                  ),
                ],
              ),
            if (showCategories) ...[
              const SizedBox(height: 6),
              CategoryFilterChips(
                categories: categories,
                selectedCategoryId: productState.categoryFilter,
                onCategorySelected: onCategorySelected,
                padding: const EdgeInsets.symmetric(horizontal: 0),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendedToggle extends StatelessWidget {
  const _RecommendedToggle({
    required this.selected,
    required this.label,
    required this.onChanged,
    this.compact = false,
  });

  final bool selected;
  final String label;
  final ValueChanged<bool> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.tertiaryContainer
        : theme.colorScheme.surface;
    final fg = selected
        ? theme.colorScheme.onTertiaryContainer
        : theme.colorScheme.onSurfaceVariant;
    final border = selected
        ? theme.colorScheme.tertiary.withValues(alpha: 0.55)
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.9);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onChanged(!selected);
        },
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 18,
                color: selected ? theme.colorScheme.tertiary : fg,
              ),
              if (!compact) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({required this.viewMode, required this.onChanged});

  final ViewMode viewMode;
  final ValueChanged<ViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ViewModeButton(
              icon: Icons.view_list_rounded,
              selected: viewMode == ViewMode.list,
              tooltip: 'List',
              onTap: () => onChanged(ViewMode.list),
            ),
            _ViewModeButton(
              icon: Icons.grid_view_rounded,
              selected: viewMode == ViewMode.grid,
              tooltip: 'Grid',
              onTap: () => onChanged(ViewMode.grid),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected ? theme.colorScheme.surface : Colors.transparent,
        elevation: selected ? 1 : 0,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(9),
          child: SizedBox(
            width: 36,
            height: 32,
            child: Icon(
              icon,
              size: 18,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
