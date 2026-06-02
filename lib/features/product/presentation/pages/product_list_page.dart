import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_grid_card.dart';

enum _ViewMode { list, grid }

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProductBloc>(),
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
  _ViewMode _viewMode = _ViewMode.list;

  @override
  void dispose() {
    _searchController.dispose();
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
              const SizedBox(width: 4),
              IconButton.filled(
                tooltip: context.l10n.addProduct,
                icon: const Icon(Icons.add),
                onPressed: () => _showProductForm(context, null),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final categories =
                    state.products
                        .map((p) => p.category)
                        .whereType<String>()
                        .toSet()
                        .toList()
                      ..sort();
                final selectedCategory =
                    categories.contains(state.categoryFilter)
                    ? state.categoryFilter
                    : null;
                final products = selectedCategory == null
                    ? state.filtered
                    : state.filtered
                          .where((p) => p.category == selectedCategory)
                          .toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: SearchBar(
                        controller: _searchController,
                        hintText: context.l10n.searchProducts,
                        leading: const Icon(Icons.search),
                        trailing: [
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (context, value, child) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context.read<ProductBloc>().add(
                                    const ProductSearchChanged(''),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                        onChanged: (q) => context.read<ProductBloc>().add(
                          ProductSearchChanged(q),
                        ),
                      ),
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              return FilterChip(
                                label: Text(context.l10n.allCategories),
                                selected: selectedCategory == null,
                                onSelected: (_) =>
                                    context.read<ProductBloc>().add(
                                      const ProductCategoryFilterChanged(null),
                                    ),
                              );
                            }
                            final cat = categories[i - 1];
                            return FilterChip(
                              label: Text(cat),
                              selected: selectedCategory == cat,
                              onSelected: (_) =>
                                  context.read<ProductBloc>().add(
                                    ProductCategoryFilterChanged(
                                      selectedCategory == cat ? null : cat,
                                    ),
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Expanded(child: _buildContent(context, state, products)),
                  ],
                );
              },
            ),
          ),
        ),
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
      return state.products.isEmpty
          ? AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.noProductsYet,
            )
          : AppEmptyState(
              icon: Icons.search_off,
              title: context.l10n.noMatchingProducts,
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
      child: _viewMode == _ViewMode.list
          ? ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => ProductTile(product: products[i]),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.76,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => ProductGridCard(product: products[i]),
            ),
    );
  }

  void _showProductForm(BuildContext context, Product? product) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: ProductFormPage(product: product),
      ),
    );
    if (result == true && context.mounted) {
      AppSnackBar.success(context, context.l10n.productSaved);
    }
  }
}
