import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_form_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_list_tile.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<CategoryBloc>()),
        BlocProvider.value(value: sl<ProductBloc>()),
      ],
      child: const _CategoryManagementView(),
    );
  }
}

class _CategoryManagementView extends StatefulWidget {
  const _CategoryManagementView();

  @override
  State<_CategoryManagementView> createState() =>
      _CategoryManagementViewState();
}

class _CategoryManagementViewState extends State<_CategoryManagementView> {
  bool _searchMode = false;
  bool _bulkMode = false;
  final _searchCtrl = TextEditingController();
  final _selectedIds = <String>{};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: BlocListener<CategoryBloc, CategoryState>(
          listenWhen: (prev, curr) =>
              curr.saveStatus == CategorySaveStatus.error &&
              prev.saveStatus != CategorySaveStatus.error,
          listener: (ctx, state) {
            final msg = switch (state.errorMessage) {
              final m when m?.contains('CategoryNameExistsException') == true =>
                ctx.l10n.categoryNameExists,
              final m when m?.contains('CategoryInUseException') == true =>
                ctx.l10n.categoryInUse,
              _ => state.errorMessage ?? ctx.l10n.errorOccurred,
            };
            AppSnackBar.error(ctx, msg);
          },
          child: BlocBuilder<ProductBloc, ProductState>(
            builder: (_, productState) {
              return BlocBuilder<CategoryBloc, CategoryState>(
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
                  return ReorderableListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    itemCount: cats.length,
                    buildDefaultDragHandles: false,
                    // ignore: deprecated_member_use
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
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final l10n = context.l10n;
    if (_searchMode) {
      return AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchCategories,
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchMode = false);
              },
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _searchMode = false),
        ),
      );
    }
    if (_bulkMode) {
      return AppBar(
        title: Text(l10n.bulkSelected(_selectedIds.length)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => setState(() {
            _bulkMode = false;
            _selectedIds.clear();
          }),
        ),
        actions: [
          if (_selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _bulkDelete(context),
            ),
        ],
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
    final q = _searchCtrl.text.trim().toLowerCase();
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

  void _bulkDelete(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<CategoryBloc>();
    showDialog<bool>(
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
    ).then((confirmed) {
      if (confirmed != true) return;
      for (final id in _selectedIds) {
        bloc.add(CategoryDeleted(id));
      }
      setState(() {
        _bulkMode = false;
        _selectedIds.clear();
      });
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

  void _showAddDialog(BuildContext context) async {
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

  void _showEditDialog(BuildContext context, Category category) async {
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
