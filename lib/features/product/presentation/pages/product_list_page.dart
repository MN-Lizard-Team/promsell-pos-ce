import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/app_search_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search_result_tile.dart';
import 'package:promsell_pos_ce/core/widgets/search_history_cubit.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/add_product_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/category_management_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/modern_product_tile.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/modern_product_grid_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_filter_bar.dart';

enum _ViewMode { list, grid }

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider.value(value: sl<CategoryBloc>()),
        BlocProvider(
          create: (_) => SearchHistoryCubit(
            sl<SettingsLocalDatasource>(),
            'product_search_history',
          )..load(),
        ),
      ],
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatefulWidget {
  const _ProductListView();

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  _ViewMode _viewMode = _ViewMode.list;
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) =>
          curr.status == ProductStatus.failure &&
          prev.status != ProductStatus.failure,
      listener: (ctx, state) {
        AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.errorOccurred);
      },
      child: BlocListener<ProductBloc, ProductState>(
        listenWhen: (prev, curr) =>
            curr.batchResultMessage != null &&
            prev.batchResultMessage != curr.batchResultMessage,
        listener: (ctx, state) {
          final count = int.tryParse(state.batchResultMessage ?? '0') ?? 0;
          if (count > 0) {
            AppSnackBar.success(ctx, ctx.l10n.batchGenerateSuccess(count));
          } else {
            AppSnackBar.info(ctx, ctx.l10n.batchGenerateNone);
          }
        },
        child: BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
          listener: (_, state) {
            if (_searchController.text != state.searchQuery) {
              _searchController.text = state.searchQuery;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.productsTitle),
              actions: [
                IconButton(
                  tooltip: context.l10n.listView,
                  icon: _viewMode == _ViewMode.list
                      ? const Icon(Icons.view_list)
                      : const Icon(Icons.view_list_outlined),
                  color: _viewMode == _ViewMode.list
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  onPressed: () => setState(() => _viewMode = _ViewMode.list),
                ),
                IconButton(
                  tooltip: context.l10n.gridView,
                  icon: _viewMode == _ViewMode.grid
                      ? const Icon(Icons.grid_view)
                      : const Icon(Icons.grid_view_outlined),
                  color: _viewMode == _ViewMode.grid
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  onPressed: () => setState(() => _viewMode = _ViewMode.grid),
                ),
                IconButton(
                  icon: const Icon(Icons.folder_outlined),
                  tooltip: context.l10n.manageCategories,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CategoryManagementPage(),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'batch_generate') {
                      _showBatchGenerateDialog(context);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'batch_generate',
                      child: Row(
                        children: [
                          const Icon(Icons.barcode_reader),
                          const SizedBox(width: 12),
                          Text(context.l10n.batchGenerateBarcodes),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final categoryState = context.watch<CategoryBloc>().state;
                  final categories = categoryState.categories;
                  final selectedCategoryId = state.categoryFilter;
                  final products = state.filtered;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                        child:
                            BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
                              builder: (ctx, historyState) {
                                return AppSearchBar(
                                  controller: _searchController,
                                  focusNode: _searchFocus,
                                  hintText: context.l10n.searchProducts,
                                  isFocused: _searchFocused,
                                  recentSearches: historyState.searches,
                                  onChanged: (q) => context
                                      .read<ProductBloc>()
                                      .add(ProductSearchChanged(q)),
                                  onSubmitted: (q) {
                                    context.read<SearchHistoryCubit>().add(q);
                                  },
                                  onRecentTap: (q) {
                                    _searchController.text = q;
                                    context.read<ProductBloc>().add(
                                      ProductSearchChanged(q),
                                    );
                                    _searchFocus.unfocus();
                                  },
                                  onRecentDismiss: (q) => context
                                      .read<SearchHistoryCubit>()
                                      .remove(q),
                                );
                              },
                            ),
                      ),
                      if (categories.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        CategoryFilterBar(
                          categories: categories,
                          selectedId: selectedCategoryId,
                          onSelected: (id) => context.read<ProductBloc>().add(
                            ProductCategoryFilterChanged(id),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      _ProductStatsBar(products: products),
                      const SizedBox(height: 8),
                      Expanded(child: _buildContent(context, state, products)),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddProductPage(context),
              heroTag: 'product_add_fab',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  void _showBatchGenerateDialog(BuildContext context) {
    final state = context.read<ProductBloc>().state;
    final l10n = context.l10n;
    final withoutBarcode = state.products
        .where((p) => p.barcode == null || p.barcode!.isEmpty)
        .length;

    if (withoutBarcode == 0) {
      AppSnackBar.info(context, l10n.batchGenerateNone);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.batchGenerateConfirmTitle),
        content: Text(l10n.batchGenerateConfirmBody(withoutBarcode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final prefix = context
                  .read<SettingsCubit>()
                  .state
                  .settings
                  .barcodeAutoGeneratePrefix;
              context.read<ProductBloc>().add(
                BarcodesBatchGenerated(prefix: prefix),
              );
            },
            child: Text(l10n.generateBarcode),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductState state,
    List<Product> products,
  ) {
    if (state.status == ProductStatus.loading ||
        state.status == ProductStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ProductStatus.failure) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: state.errorMessage ?? context.l10n.errorOccurred,
      );
    }
    if (products.isEmpty) {
      if (state.products.isEmpty) {
        return AppEmptyState(
          icon: Icons.inventory_2_outlined,
          title: context.l10n.noProductsYet,
        );
      }
      if (state.searchQuery.isNotEmpty) {
        return SearchEmptyState(
          query: state.searchQuery,
          onClear: () {
            _searchController.clear();
            context.read<ProductBloc>().add(const ProductSearchChanged(''));
          },
        );
      }
      return AppEmptyState(
        icon: Icons.filter_list_off,
        title: context.l10n.noProductsInCategory,
        actionLabel: context.l10n.clearFilters,
        onAction: () {
          _searchController.clear();
          context.read<ProductBloc>().add(const ProductSearchChanged(''));
          context.read<ProductBloc>().add(
            const ProductCategoryFilterChanged(null),
          );
        },
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<ProductBloc>();
        bloc.add(const ProductsSubscribed());
        await bloc.stream.firstWhere(
          (s) =>
              s.status == ProductStatus.success ||
              s.status == ProductStatus.failure,
        );
      },
      child: state.searchQuery.isNotEmpty
          ? _viewMode == _ViewMode.list
                ? ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => SearchResultTile(
                      product: products[i],
                      query: state.searchQuery,
                      onTap: () => _showEdit(context, products[i]),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: products.length,
                    itemBuilder: (_, i) =>
                        ModernProductGridCard(product: products[i]),
                  )
          : _viewMode == _ViewMode.list
          ? ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => ModernProductTile(product: products[i]),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) =>
                  ModernProductGridCard(product: products[i]),
            ),
    );
  }

  void _showAddProductPage(BuildContext context) async {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
            BlocProvider(
              create: (_) =>
                  AddProductDraftCubit(sl<SettingsLocalDatasource>()),
            ),
          ],
          child: const AddProductPage(),
        ),
      ),
    );
    if (result == true && context.mounted) {
      AppSnackBar.success(context, context.l10n.productSaved);
    }
  }

  void _showEdit(BuildContext context, Product product) {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: ProductFormPage(product: product),
        ),
      ),
    );
  }
}

class _ProductStatsBar extends StatelessWidget {
  const _ProductStatsBar({required this.products});
  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = products.where((p) => p.isActive).length;
    final lowStock = products
        .where((p) => p.trackStock && p.stock > 0 && p.stock <= 5)
        .length;
    final outOfStock = products
        .where((p) => p.trackStock && p.stock == 0)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.inventory_2,
            label: '$active',
            subtitle: context.l10n.productsCount,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          if (lowStock > 0)
            _StatChip(
              icon: Icons.warning,
              label: '$lowStock',
              subtitle: context.l10n.lowStock,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          if (outOfStock > 0) ...[
            const SizedBox(width: 8),
            _StatChip(
              icon: Icons.error,
              label: '$outOfStock',
              subtitle: context.l10n.outOfStock,
              color: theme.colorScheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
