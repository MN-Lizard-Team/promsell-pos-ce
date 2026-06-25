import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';

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

    return Semantics(
      button: true,
      label: '${category.name}, $productCount ${context.l10n.productsCount}',
      child: Card(
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
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteCategory),
        content: Text(context.l10n.confirmDeleteCategory(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(dialogContext);
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
