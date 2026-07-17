import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_app_bars.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_form_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart';

enum _PendingCategorySnack { none, saved, deletedOne, deletedMany, reorder }

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  final _searchCtrl = TextEditingController();
  bool _searchMode = false;
  bool _bulkMode = false;
  final _selectedIds = <String>{};
  String _searchQuery = '';
  _PendingCategorySnack _pendingSnack = _PendingCategorySnack.none;
  int _pendingDeleteCount = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<CategoryBloc>()),
        BlocProvider.value(value: sl<ProductBloc>()),
      ],
      child: PopScope(
        canPop: !_searchMode && !_bulkMode,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_searchMode) {
            _searchCtrl.clear();
            setState(() {
              _searchMode = false;
              _searchQuery = '';
            });
          } else if (_bulkMode) {
            setState(() {
              _bulkMode = false;
              _selectedIds.clear();
            });
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: BlocListener<CategoryBloc, CategoryState>(
              listenWhen: (prev, curr) =>
                  (curr.saveStatus == CategorySaveStatus.saved &&
                      prev.saveStatus != CategorySaveStatus.saved) ||
                  (curr.saveStatus == CategorySaveStatus.error &&
                      prev.saveStatus != CategorySaveStatus.error),
              listener: (ctx, state) {
                if (state.saveStatus == CategorySaveStatus.error) {
                  final msg = switch (state.errorMessage) {
                    final m
                        when m?.contains('CategoryNameExistsException') ==
                            true =>
                      ctx.l10n.categoryNameExists,
                    final m
                        when m?.contains('CategoryInUseException') == true =>
                      ctx.l10n.categoryInUse,
                    _ => state.errorMessage ?? ctx.l10n.errorOccurred,
                  };
                  AppSnackBar.error(ctx, msg);
                  _pendingSnack = _PendingCategorySnack.none;
                  return;
                }
                if (state.saveStatus == CategorySaveStatus.saved) {
                  final kind = _pendingSnack;
                  _pendingSnack = _PendingCategorySnack.none;
                  switch (kind) {
                    case _PendingCategorySnack.saved:
                      AppSnackBar.success(ctx, ctx.l10n.categorySaved);
                    case _PendingCategorySnack.deletedOne:
                      AppSnackBar.success(ctx, ctx.l10n.categoryDeleted);
                    case _PendingCategorySnack.deletedMany:
                      AppSnackBar.success(
                        ctx,
                        ctx.l10n.categoriesDeleted(_pendingDeleteCount),
                      );
                    case _PendingCategorySnack.reorder:
                    case _PendingCategorySnack.none:
                      break;
                  }
                }
              },
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state.status == CategoryStatus.loading ||
                      state.status == CategoryStatus.initial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == CategoryStatus.failure) {
                    return AppEmptyState(
                      icon: Icons.error_outline,
                      title: state.errorMessage ?? context.l10n.errorOccurred,
                    );
                  }

                  final all = state.categories;
                  final cats = _filteredCategories(all);

                  if (all.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.folder_open_outlined,
                      title: context.l10n.noCategoriesYet,
                      actionLabel: context.l10n.addCategory,
                      onAction: () => _showAddDialog(context),
                    );
                  }

                  if (cats.isEmpty) {
                    return AppEmptyState(
                      icon: Icons.search_off,
                      title: context.l10n.noCategoriesFound,
                      message: context.l10n.tryDifferentKeyword,
                      actionLabel: context.l10n.clearSearch,
                      onAction: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searchMode = false;
                          _searchQuery = '';
                        });
                      },
                    );
                  }

                  return BlocSelector<ProductBloc, ProductState, List<Product>>(
                    selector: (productState) => productState.products,
                    builder: (context, products) {
                      final counts = <String, int>{};
                      for (final product in products) {
                        final categoryId = product.categoryId;
                        if (categoryId != null) {
                          counts.update(
                            categoryId,
                            (count) => count + 1,
                            ifAbsent: () => 1,
                          );
                        }
                      }
                      final canReorder =
                          !_bulkMode &&
                          !_searchMode &&
                          state.saveStatus != CategorySaveStatus.saving;
                      final showHint = canReorder && cats.length > 1;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showHint)
                            Material(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.drag_handle,
                                      size: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        context.l10n.categoryReorderHint,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Expanded(
                            child: ReorderableListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                              itemCount: cats.length,
                              buildDefaultDragHandles: false,
                              onReorderItem: canReorder
                                  ? (oldIndex, newIndex) => _onReorder(
                                      context,
                                      cats,
                                      oldIndex,
                                      newIndex,
                                    )
                                  : null,
                              itemBuilder: (_, i) {
                                final cat = cats[i];
                                final count = counts[cat.id] ?? 0;
                                return CategoryListTile(
                                  key: ValueKey(cat.id),
                                  category: cat,
                                  productCount: count,
                                  index: i,
                                  showDragHandle: !_bulkMode && !_searchMode,
                                  selected: _selectedIds.contains(cat.id),
                                  selectionMode: _bulkMode,
                                  onTap: _bulkMode
                                      ? () => _toggleSelect(cat.id)
                                      : () => _showEditDialog(context, cat),
                                  onDelete: () =>
                                      _showDeleteFlow(context, [cat]),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          floatingActionButton: !_bulkMode
              ? FloatingActionButton(
                  onPressed: () => _showAddDialog(context),
                  heroTag: 'category_add_fab',
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = context.l10n;
    if (_searchMode) {
      return CategorySearchAppBar(
        controller: _searchCtrl,
        onChanged: (value) => setState(() => _searchQuery = value),
        onClose: () {
          _searchCtrl.clear();
          setState(() {
            _searchMode = false;
            _searchQuery = '';
          });
        },
      );
    }
    if (_bulkMode) {
      return CategoryBulkAppBar(
        selectedCount: _selectedIds.length,
        onClose: () => setState(() {
          _bulkMode = false;
          _selectedIds.clear();
        }),
        onBulkDelete: () => _bulkDelete(context),
      );
    }
    return AppBar(
      title: Text(l10n.categoryManagementTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => setState(() => _searchMode = true),
        ),
        IconButton(
          icon: const Icon(Icons.checklist),
          onPressed: () => setState(() => _bulkMode = true),
        ),
      ],
    );
  }

  List<Category> _filteredCategories(List<Category> all) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _bulkDelete(BuildContext context) async {
    final categories = context
        .read<CategoryBloc>()
        .state
        .categories
        .where((category) => _selectedIds.contains(category.id))
        .toList();
    final deleted = await _showDeleteFlow(context, categories);
    if (!mounted || !deleted) return;
    setState(() {
      _bulkMode = false;
      _selectedIds.clear();
    });
  }

  /// Returns true when delete was confirmed and dispatched.
  Future<bool> _showDeleteFlow(
    BuildContext context,
    List<Category> categories,
  ) async {
    if (categories.isEmpty) return false;
    final categoryIds = categories.map((category) => category.id).toSet();
    final products = context.read<ProductBloc>().state.products;
    final affectedCount = products
        .where((product) => categoryIds.contains(product.categoryId))
        .length;
    final targets = context
        .read<CategoryBloc>()
        .state
        .categories
        .where((category) => !categoryIds.contains(category.id))
        .toList();
    String? moveTargetId;
    final l10n = context.l10n;
    final isSingle = categories.length == 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            isSingle
                ? l10n.deleteCategory
                : l10n.bulkDeleteConfirm(categories.length),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSingle
                    ? l10n.confirmDeleteCategory(categories.first.name)
                    : l10n.bulkDeleteConfirm(categories.length),
              ),
              if (affectedCount > 0) ...[
                const SizedBox(height: 12),
                Text(l10n.deleteCategoryProductsImpact(affectedCount)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: moveTargetId,
                  decoration: InputDecoration(labelText: l10n.moveProduct),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.uncategorized),
                    ),
                    ...targets.map(
                      (category) => DropdownMenuItem<String?>(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => moveTargetId = value),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !context.mounted) return false;
    _pendingSnack = isSingle
        ? _PendingCategorySnack.deletedOne
        : _PendingCategorySnack.deletedMany;
    _pendingDeleteCount = categories.length;
    context.read<CategoryBloc>().add(
      CategoriesDeleted(
        categories.map((category) => category.id).toList(),
        moveProductsToCategoryId: moveTargetId,
      ),
    );
    return true;
  }

  void _onReorder(
    BuildContext context,
    List<Category> cats,
    int oldIndex,
    int newIndex,
  ) {
    if (_searchMode || _bulkMode || oldIndex == newIndex) return;
    final reordered = List<Category>.from(cats);
    if (newIndex < 0 || newIndex >= reordered.length) return;
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    _pendingSnack = _PendingCategorySnack.reorder;
    context.read<CategoryBloc>().add(
      CategoriesReordered(reordered.map((category) => category.id).toList()),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<CategoryFormResult>(
      context: context,
      builder: (_) => const CategoryFormDialog(),
    );
    if (result != null && context.mounted) {
      _pendingSnack = _PendingCategorySnack.saved;
      context.read<CategoryBloc>().add(
        CategoryAdded(
          name: result.name,
          sortOrder: result.sortOrder,
          color: result.color,
          iconName: result.iconName,
        ),
      );
    }
  }

  Future<void> _showEditDialog(BuildContext context, Category category) async {
    final result = await showDialog<CategoryFormResult>(
      context: context,
      builder: (_) => CategoryFormDialog(category: category),
    );
    if (result != null && context.mounted) {
      _pendingSnack = _PendingCategorySnack.saved;
      context.read<CategoryBloc>().add(
        CategoryUpdated(
          category.copyWith(
            name: result.name,
            sortOrder: result.sortOrder,
            color: result.color,
            iconName: result.iconName,
          ),
        ),
      );
    }
  }
}
