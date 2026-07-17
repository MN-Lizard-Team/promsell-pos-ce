import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
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
    final hasCategory = selectedCategory != null;

    return Semantics(
      button: true,
      label: context.l10n.categoryLabel,
      value: selectedCategory?.name ?? context.l10n.noCategorySelected,
      child: InkWell(
        onTap: () => _pickCategory(context),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: context.l10n.categoryLabel,
            // No prefix icon — match text fields without leading icons.
            suffixIcon: hasCategory
                ? IconButton(
                    key: const ValueKey('product-form-category-clear'),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                    icon: const Icon(Icons.clear, size: 20),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => onChanged(null),
                  )
                : const Icon(Icons.keyboard_arrow_down_outlined),
          ),
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
                      context.l10n.loading,
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
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickCategory(BuildContext context) async {
    final cat = await showCategoryPicker(
      context,
      selectedId: selectedCategory?.id,
      showNoneOption: true,
    );
    if (cat != null) {
      // Empty id = "No category" sentinel from picker.
      onChanged(cat.id.isEmpty ? null : cat);
    }
  }
}
