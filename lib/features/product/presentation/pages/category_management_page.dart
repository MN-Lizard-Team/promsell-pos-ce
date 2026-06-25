import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_app_bars.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_form_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart';

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
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: BlocListener<CategoryBloc, CategoryState>(
            listenWhen: (prev, curr) =>
                curr.saveStatus == CategorySaveStatus.error &&
                prev.saveStatus != CategorySaveStatus.error,
            listener: (ctx, state) {
              final msg = switch (state.errorMessage) {
                final m
                    when m?.contains('CategoryNameExistsException') == true =>
                  ctx.l10n.categoryNameExists,
                final m when m?.contains('CategoryInUseException') == true =>
                  ctx.l10n.categoryInUse,
                _ => state.errorMessage ?? ctx.l10n.errorOccurred,
              };
              AppSnackBar.error(ctx, msg);
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
                final cats = _filteredCategories(state.categories);
                if (cats.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.folder_open_outlined,
                    title: context.l10n.noCategoriesYet,
                    actionLabel: context.l10n.addCategory,
                    onAction: () => _showAddDialog(context),
                  );
                }
                final productState = context.read<ProductBloc>().state;
                return ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemCount: cats.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) =>
                      _onReorder(context, cats, oldIndex, newIndex),
                  itemBuilder: (_, i) {
                    final cat = cats[i];
                    final count = productState.products
                        .where((p) => p.categoryId == cat.id)
                        .length;
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
                      onDelete: () => context.read<CategoryBloc>().add(
                        CategoryDeleted(cat.id),
                      ),
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
          icon: const Icon(Icons.select_all),
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
    final l10n = context.l10n;
    final bloc = context.read<CategoryBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.bulkDeleteConfirm(_selectedIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final toDelete = List<String>.from(_selectedIds);
    for (final id in toDelete) {
      bloc.add(CategoryDeleted(id));
    }
    if (!mounted) return;
    setState(() {
      _bulkMode = false;
      _selectedIds.clear();
    });
  }

  void _onReorder(
    BuildContext context,
    List<Category> cats,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex > oldIndex) newIndex--;
    final reordered = List<Category>.from(cats);
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    final reorderedIds = reordered.map((c) => c.id).toList();
    final allCats = context.read<CategoryBloc>().state.categories;
    final fullOrder = <String>[];
    for (final c in allCats) {
      if (reorderedIds.contains(c.id)) {
        fullOrder.add(reorderedIds.removeAt(0));
      } else {
        fullOrder.add(c.id);
      }
    }
    context.read<CategoryBloc>().add(CategoriesReordered(fullOrder));
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<CategoryFormResult>(
      context: context,
      builder: (_) => const CategoryFormDialog(),
    );
    if (result != null && context.mounted) {
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
