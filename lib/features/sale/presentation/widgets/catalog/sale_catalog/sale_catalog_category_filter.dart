import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';

class SaleCatalogCategoryFilter extends StatelessWidget {
  const SaleCatalogCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
  });

  final List categories;
  final String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 44,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface,
            theme.colorScheme.surface.withValues(alpha: 0),
          ],
          stops: const [0, 0.85, 1],
        ).createShader(bounds),
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length + 2,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final isAll = index == 0;
            final isNone = index == categories.length + 1;
            final category = isAll || isNone ? null : categories[index - 1];
            final selected = isNone
                ? selectedCategoryId == kNoCategoryFilter
                : selectedCategoryId == category?.id;

            final catColor = isAll || isNone
                ? null
                : parseCategoryColor(category!.color);
            final catIcon = isAll || isNone
                ? null
                : parseCategoryIcon(category!.iconName);
            return ChoiceChip(
              avatar: isAll || isNone || catColor == null
                  ? null
                  : Icon(
                      catIcon,
                      size: 16,
                      color: selected
                          ? theme.colorScheme.onPrimaryContainer
                          : catColor,
                    ),
              label: Text(
                isAll
                    ? context.l10n.allCategories
                    : isNone
                    ? context.l10n.noCategory
                    : category!.name,
              ),
              selected: selected,
              selectedColor: theme.colorScheme.primaryContainer,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: selected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.secondary,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
              onSelected: (_) {
                HapticFeedback.selectionClick();
                context.read<ProductBloc>().add(
                  ProductCategoryFilterChanged(
                    isNone ? kNoCategoryFilter : category?.id,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
