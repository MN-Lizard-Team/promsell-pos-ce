import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

class CategoryListTile extends StatelessWidget {
  const CategoryListTile({
    super.key,
    required this.category,
    this.productCount = 0,
    this.index,
    this.showDragHandle = false,
    this.onTap,
    this.onDelete,
    this.selected = false,
    this.selectionMode = false,
  });

  final Category category;
  final int productCount;
  final int? index;
  final bool showDragHandle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;
  final bool selectionMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catColor = parseCategoryColor(category.color);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  parseCategoryIcon(category.iconName),
                  color: catColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$productCount ${context.l10n.productsCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (showDragHandle && index != null)
                ReorderableDragStartListener(
                  index: index!,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.drag_handle,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else if (selectionMode)
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                )
              else if (onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteCategory),
        content: Text(context.l10n.confirmDeleteCategory(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(context);
            },
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

Color parseCategoryColor(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.blue;
  try {
    return Color(int.parse('FF$hex', radix: 16));
  } catch (_) {
    return Colors.blue;
  }
}

IconData parseCategoryIcon(String? name) {
  return categoryIconMap[name] ?? Icons.folder_outlined;
}

const categoryIconMap = <String, IconData>{
  'folder_outlined': Icons.folder_outlined,
  'restaurant_outlined': Icons.restaurant_outlined,
  'shopping_basket_outlined': Icons.shopping_basket_outlined,
  'local_drink_outlined': Icons.local_drink_outlined,
  'cake_outlined': Icons.cake_outlined,
  'local_cafe_outlined': Icons.local_cafe_outlined,
  'fastfood_outlined': Icons.fastfood_outlined,
  'local_pizza_outlined': Icons.local_pizza_outlined,
  'icecream_outlined': Icons.icecream_outlined,
  'kitchen_outlined': Icons.kitchen_outlined,
  'checkroom_outlined': Icons.checkroom_outlined,
  'smartphone_outlined': Icons.smartphone_outlined,
  'computer_outlined': Icons.computer_outlined,
  'chair_outlined': Icons.chair_outlined,
  'pets_outlined': Icons.pets_outlined,
  'sports_soccer_outlined': Icons.sports_soccer_outlined,
  'brush_outlined': Icons.brush_outlined,
  'local_hospital_outlined': Icons.local_hospital_outlined,
  'school_outlined': Icons.school_outlined,
  'build_outlined': Icons.build_outlined,
  'more_horiz_outlined': Icons.more_horiz_outlined,
};
