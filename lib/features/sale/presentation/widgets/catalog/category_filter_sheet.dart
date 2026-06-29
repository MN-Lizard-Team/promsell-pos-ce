import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart';

class CategoryFilterSheet extends StatefulWidget {
  const CategoryFilterSheet({super.key, this.scrollController});

  final ScrollController? scrollController;

  static void show(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 300),
        reverseDuration: Duration(milliseconds: 200),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) =>
              CategoryFilterSheet(scrollController: scrollController),
        ),
      ),
    );
  }

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final state = context.watch<ProductBloc>().state;
    final categories = context.watch<CategoryBloc>().state.categories;
    final activeProducts = state.products.where((p) => p.isActive).toList();
    final selected = state.categoryFilter;

    int countFor(String? categoryId) {
      if (categoryId == null) return activeProducts.length;
      if (categoryId == kNoCategoryFilter) {
        return activeProducts.where((p) => p.categoryId == null).length;
      }
      return activeProducts.where((p) => p.categoryId == categoryId).length;
    }

    void select(String? value) {
      context.read<ProductBloc>().add(ProductCategoryFilterChanged(value));
      Navigator.pop(context);
    }

    final totalProducts = activeProducts.length;
    final uncategorizedCount = activeProducts
        .where((p) => p.categoryId == null)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.25,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Row(
              children: [
                Text(
                  l10n.filterCategory,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (selected != null)
                  TextButton.icon(
                    onPressed: () => select(null),
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: Text(l10n.filterAll),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _statCard(
                  theme,
                  '$totalProducts',
                  l10n.filterAll,
                  Icons.inventory_2_outlined,
                ),
                const SizedBox(width: 8),
                _statCard(
                  theme,
                  '${categories.length}',
                  l10n.filterCategory,
                  Icons.label_outline,
                ),
                const SizedBox(width: 8),
                _statCard(
                  theme,
                  '$uncategorizedCount',
                  l10n.noCategory,
                  Icons.category_outlined,
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              itemCount: categories.length + 2,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _categoryTile(
                    label: l10n.allCategories,
                    count: countFor(null),
                    icon: Icons.apps,
                    iconColor: theme.colorScheme.primary,
                    selected: selected == null,
                    onTap: () => select(null),
                    theme: theme,
                  );
                }
                if (i == 1) {
                  return _categoryTile(
                    label: l10n.noCategory,
                    count: countFor(kNoCategoryFilter),
                    icon: Icons.block_outlined,
                    iconColor: theme.colorScheme.onSurfaceVariant,
                    selected: selected == kNoCategoryFilter,
                    onTap: () => select(kNoCategoryFilter),
                    theme: theme,
                  );
                }
                final cat = categories[i - 2];
                final catColor = parseCategoryColor(cat.color);
                return _categoryTile(
                  label: cat.name,
                  count: countFor(cat.id),
                  icon: parseCategoryIcon(cat.iconName),
                  iconColor: catColor,
                  selected: selected == cat.id,
                  onTap: () => select(cat.id),
                  theme: theme,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(ThemeData theme, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _categoryTile({
  required String label,
  required int count,
  required IconData icon,
  required Color iconColor,
  required bool selected,
  required VoidCallback onTap,
  required ThemeData theme,
}) {
  return Material(
    color: Colors.transparent,
    child: ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (selected) ...[
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selected: selected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      onTap: onTap,
    ),
  );
}
