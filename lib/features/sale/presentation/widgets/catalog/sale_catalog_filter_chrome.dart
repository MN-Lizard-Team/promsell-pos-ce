import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/category_filter_chips.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_filter_bar.dart';

/// Sale catalog filter chrome — paper tools row + category tabs (no admin card mush).
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
    final pos = context.posTheme;
    final l10n = context.l10n;

    return Material(
      color: pos.billStubPaper,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: pos.billStubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (showCategories)
                  Text(
                    l10n.saleCategoryTabsLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
                else
                  const Spacer(),
                if (showCategories) const Spacer(),
                // Recommended = merchandising; filter + view = list tools.
                if (hasRecommended) ...[
                  _ToolChip(
                    selected: recommendedOnly,
                    icon: recommendedOnly
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    tooltip: l10n.saleRecommendedFilter,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onRecommendedChanged(!recommendedOnly);
                    },
                    accentWhenSelected: true,
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 24, color: pos.billStubBorder),
                  const SizedBox(width: 8),
                ],
                SaleFilterBar(productState: productState, compact: true),
                const SizedBox(width: 6),
                _ViewModeToggle(
                  viewMode: viewMode,
                  onChanged: onViewModeChanged,
                ),
              ],
            ),
            if (showCategories) ...[
              const SizedBox(height: 8),
              CategoryFilterChips(
                categories: categories,
                selectedCategoryId: productState.categoryFilter,
                onCategorySelected: onCategorySelected,
                padding: EdgeInsets.zero,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Outline tool chip — paper language (not filled primary unless active filter).
class _ToolChip extends StatelessWidget {
  const _ToolChip({
    required this.selected,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.accentWhenSelected = false,
  });

  final bool selected;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool accentWhenSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final bg = selected && accentWhenSelected
        ? theme.colorScheme.tertiaryContainer
        : pos.billStubPaper;
    final border = selected && accentWhenSelected
        ? theme.colorScheme.tertiary.withValues(alpha: 0.45)
        : pos.billStubBorder;
    final fg = selected && accentWhenSelected
        ? theme.colorScheme.tertiary
        : theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: selected,
        label: tooltip,
        child: Material(
          color: bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: border),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, size: 18, color: fg),
            ),
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
    final pos = context.posTheme;

    return Material(
      color: pos.billStubPaper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: pos.billStubBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
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
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 32,
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
