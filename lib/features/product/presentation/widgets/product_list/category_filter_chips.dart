import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;

/// Horizontal category chips — shared by Product list and Sale catalog.
///
/// Selected chip uses filled primary (mock-style). Fade edge uses a white
/// gradient so it works on both surface and slate catalog backgrounds.
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.height = 42,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final EdgeInsets padding;
  final double height;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      height: height,
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
          stops: [0.0, 0.88, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          padding: padding,
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 2,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final isAll = index == 0;
            final isNone = index == categories.length + 1;
            final category = isAll || isNone ? null : categories[index - 1];
            final selected = isNone
                ? selectedCategoryId == kNoCategoryFilter
                : isAll
                ? selectedCategoryId == null
                : selectedCategoryId == category?.id;
            final catColor = isAll || isNone
                ? null
                : parseCategoryColor(category!.color);
            final catIcon = isAll || isNone
                ? null
                : parseCategoryIcon(category!.iconName);

            final label = isAll
                ? l10n.allCategories
                : isNone
                ? l10n.noCategory
                : category!.name;

            return _CategoryPill(
              label: label,
              selected: selected,
              leading: isAll
                  ? Icons.grid_view_rounded
                  : isNone
                  ? Icons.category_outlined
                  : catIcon,
              accentColor: catColor,
              onTap: () {
                HapticFeedback.selectionClick();
                if (isAll) {
                  onCategorySelected(null);
                } else if (isNone) {
                  onCategorySelected(kNoCategoryFilter);
                } else {
                  onCategorySelected(category?.id);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
    this.accentColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leading;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected ? theme.colorScheme.primary : theme.colorScheme.surface;
    final fg = selected
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.85);
    final iconColor = selected
        ? theme.colorScheme.onPrimary
        : (accentColor ?? theme.colorScheme.onSurfaceVariant);

    return Material(
      color: bg,
      elevation: selected ? 1.5 : 0,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: borderColor, width: selected ? 0 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                Icon(leading, size: 16, color: iconColor),
                const SizedBox(width: 6),
              ] else if (accentColor != null && !selected) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
