import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;

/// Compact category affordance for product/sale tiles.
///
/// - [CategoryCueStyle.label]: 16px icon box + muted name (POS-friendly).
/// - [CategoryCueStyle.pill]: tinted chip with colored name (admin density).
/// - [CategoryCueStyle.dot]: icon box only.
enum CategoryCueStyle { label, pill, dot }

class CategoryCue extends StatelessWidget {
  const CategoryCue({
    super.key,
    required this.category,
    this.style = CategoryCueStyle.label,
    this.compact = false,
  });

  final Category category;
  final CategoryCueStyle style;

  /// Slightly tighter type/padding for constrained cells (sale grid).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = parseCategoryColor(category.color);
    final icon = parseCategoryIcon(category.iconName);

    return switch (style) {
      CategoryCueStyle.dot => _IconBox(color: color, icon: icon, size: 16),
      CategoryCueStyle.pill => Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 6,
          vertical: compact ? 1 : 2,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(compact ? 4 : 6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 9 : 10,
                ),
              ),
            ),
          ],
        ),
      ),
      CategoryCueStyle.label => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconBox(color: color, icon: icon, size: compact ? 14 : 16),
          SizedBox(width: compact ? 4 : 6),
          Flexible(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    };
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.color, required this.icon, required this.size});

  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: size * 0.625, color: color),
    );
  }
}
