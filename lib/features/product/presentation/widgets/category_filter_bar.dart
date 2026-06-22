import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_list_tile.dart'
    show parseCategoryColor, parseCategoryIcon;

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.categories,
    this.selectedId,
    this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 2,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            final selected = selectedId == null || selectedId!.isEmpty;
            return _FilterChip(
              icon: Icons.category,
              label: context.l10n.allCategories,
              selected: selected,
              color: theme.colorScheme.primary,
              onTap: () => onSelected?.call(null),
            );
          }
          if (i == categories.length + 1) {
            final selected = selectedId == kNoCategoryFilter;
            return _FilterChip(
              icon: Icons.folder_off_outlined,
              label: context.l10n.noCategory,
              selected: selected,
              color: theme.colorScheme.outline,
              onTap: () =>
                  onSelected?.call(selected ? null : kNoCategoryFilter),
            );
          }
          final cat = categories[i - 1];
          final selected = selectedId == cat.id;
          final dbColor = parseCategoryColor(cat.color);
          final dbIcon = parseCategoryIcon(cat.iconName);
          final hasDbColor = cat.color != null && cat.color!.isNotEmpty;
          final style = !hasDbColor
              ? CategoryStyleResolver.resolve(cat.name)
              : null;
          final color = hasDbColor
              ? dbColor
              : (style?.color == Colors.transparent
                    ? theme.colorScheme.primary
                    : style?.color ?? theme.colorScheme.primary);
          final icon = cat.iconName != null && cat.iconName!.isNotEmpty
              ? dbIcon
              : (style?.icon ?? Icons.folder_outlined);
          return _FilterChip(
            icon: icon,
            label: cat.name,
            selected: selected,
            color: color,
            onTap: () => onSelected?.call(selected ? null : cat.id),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? color : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
