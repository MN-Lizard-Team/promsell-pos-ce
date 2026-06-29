import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_picker_bottom_sheet.dart';

class CategoryField extends StatelessWidget {
  const CategoryField({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  final Category? selectedCategory;
  final ValueChanged<Category?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _pickCategory(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: parseCategoryColor(
                  selectedCategory?.color,
                ).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                parseCategoryIcon(selectedCategory?.iconName),
                size: 16,
                color: parseCategoryColor(selectedCategory?.color),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (ctx, state) {
                  final isLoading =
                      state.status == CategoryStatus.loading &&
                      state.categories.isEmpty;
                  if (isLoading) {
                    return Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ctx.l10n.loading,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(
                    selectedCategory?.name ?? context.l10n.noCategorySelected,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: selectedCategory == null
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  );
                },
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _pickCategory(BuildContext context) async {
    final result = await showCategoryPicker(
      context,
      selectedId: selectedCategory?.id,
      showNoneOption: true,
    );
    if (result == null) return;
    if (result.id.isEmpty) {
      onChanged(null);
    } else {
      onChanged(result);
    }
  }
}
