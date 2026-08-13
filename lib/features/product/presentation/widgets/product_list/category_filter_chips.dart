import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;

/// Horizontal category chips — Product list + Sale catalog.
///
/// Paper-stub language: r≈10, ink on paper; selected = primary fill (tab affordance).
/// Shows a fade gradient on the right edge when more chips can be scrolled.
class CategoryFilterChips extends StatefulWidget {
  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.height = 40,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;
  final EdgeInsets padding;
  final double height;

  @override
  State<CategoryFilterChips> createState() => _CategoryFilterChipsState();
}

class _CategoryFilterChipsState extends State<CategoryFilterChips> {
  final _scrollController = ScrollController();
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    final canRight = pos.pixels < pos.maxScrollExtent - 1;
    if (canRight != _canScrollRight) {
      setState(() => _canScrollRight = canRight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: widget.height,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            scheme.surface,
            scheme.surface,
            scheme.surface.withValues(alpha: 0),
          ],
          stops: _canScrollRight
              ? const [0.0, 0.9, 1.0]
              : const [0.0, 1.0, 1.0],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          controller: _scrollController,
          padding: widget.padding,
          scrollDirection: Axis.horizontal,
          itemCount: widget.categories.length + 2,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (_, index) {
            final isAll = index == 0;
            final isNone = index == widget.categories.length + 1;
            final category = isAll || isNone
                ? null
                : widget.categories[index - 1];
            final selected = isNone
                ? widget.selectedCategoryId == kNoCategoryFilter
                : isAll
                ? widget.selectedCategoryId == null
                : widget.selectedCategoryId == category?.id;
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
                  widget.onCategorySelected(null);
                } else if (isNone) {
                  widget.onCategorySelected(kNoCategoryFilter);
                } else {
                  widget.onCategorySelected(category?.id);
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

  static const _radius = 10.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = selected ? scheme.primary : scheme.surface;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    final borderColor = selected
        ? scheme.primary
        : scheme.outlineVariant.withValues(alpha: 0.75);
    final iconColor = selected
        ? scheme.onPrimary
        : (accentColor ?? scheme.onSurfaceVariant);

    return Material(
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
        side: BorderSide(color: borderColor, width: selected ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                Icon(leading, size: 16, color: iconColor),
                const SizedBox(width: 5),
              ] else if (accentColor != null && !selected) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
