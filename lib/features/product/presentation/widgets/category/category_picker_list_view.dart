import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';

class CategoryPickerListView extends StatefulWidget {
  const CategoryPickerListView({
    super.key,
    this.selectedId,
    required this.onSelected,
    this.useListTile = false,
    this.showNoneOption = false,
    this.emptyAction,
  });

  final String? selectedId;
  final ValueChanged<Category> onSelected;
  final bool useListTile;
  final bool showNoneOption;
  final VoidCallback? emptyAction;

  @override
  State<CategoryPickerListView> createState() => _CategoryPickerListViewState();
}

class _CategoryPickerListViewState extends State<CategoryPickerListView> {
  final _searchCtrl = TextEditingController();
  final _searchText = ValueNotifier<String>('');

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    disposeTextEditingControllerAfterFrame(_searchCtrl);
    _searchText.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _searchText.value = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: context.l10n.searchCategories,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: ValueListenableBuilder<String>(
                valueListenable: _searchText,
                builder: (context, text, _) {
                  if (text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  );
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHigh,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (v) {
              _searchText.value = v;
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state.status == CategoryStatus.loading ||
                  state.status == CategoryStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              final query = _searchText.value.toLowerCase();
              final filtered = query.isEmpty
                  ? state.categories
                  : state.categories
                        .where((c) => c.name.toLowerCase().contains(query))
                        .toList();

              if (state.categories.isEmpty) {
                return AppEmptyState(
                  icon: Icons.folder_open_outlined,
                  title: context.l10n.noCategoriesYet,
                  actionLabel: widget.emptyAction != null
                      ? context.l10n.manageCategories
                      : null,
                  onAction: widget.emptyAction,
                );
              }

              final noneSelected =
                  widget.selectedId == null || widget.selectedId!.isEmpty;
              final itemCount =
                  filtered.length + (widget.showNoneOption ? 1 : 0);

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                itemCount: itemCount,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  if (widget.showNoneOption && i == 0) {
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.block_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(context.l10n.noCategory),
                      trailing: noneSelected
                          ? Icon(
                              Icons.check_circle,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onSelected(
                          Category(
                            id: '',
                            name: context.l10n.noCategory,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );
                      },
                    );
                  }

                  final catIndex = widget.showNoneOption ? i - 1 : i;
                  final cat = filtered[catIndex];
                  final selected = widget.selectedId == cat.id;

                  if (widget.useListTile) {
                    return CategoryListTile(
                      category: cat,
                      selected: selected,
                      selectionMode: true,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onSelected(cat);
                      },
                    );
                  }

                  final catColor = parseCategoryColor(cat.color);
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        parseCategoryIcon(cat.iconName),
                        size: 20,
                        color: catColor,
                      ),
                    ),
                    title: Text(cat.name),
                    trailing: selected
                        ? Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      widget.onSelected(cat);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
