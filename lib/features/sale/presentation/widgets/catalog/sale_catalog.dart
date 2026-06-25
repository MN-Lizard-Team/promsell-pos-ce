import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_result_tile.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog/sale_catalog_category_filter.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog/sale_catalog_search_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_product_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleCatalog extends StatefulWidget {
  const SaleCatalog({super.key});

  @override
  State<SaleCatalog> createState() => _SaleCatalogState();
}

class _SaleCatalogState extends State<SaleCatalog> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        context.read<ProductBloc>().add(const ProductSearchChanged(''));
      }
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
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (_, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (ctx, state) {
          if (state.status == ProductStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProductStatus.failure) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: state.errorMessage ?? ctx.l10n.errorOccurred,
            );
          }

          final activeProducts = state.filtered
              .where((product) => product.isActive)
              .toList();
          final categories = ctx.watch<CategoryBloc>().state.categories;
          final selectedCategoryId = state.categoryFilter;
          final products = activeProducts;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SaleCatalogSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    isFocused: _searchFocused,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SaleCatalogCategoryFilter(
                      categories: categories,
                      selectedCategoryId: selectedCategoryId,
                    ),
                    if (state.searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          ctx.l10n.searchResultsCount(products.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              if (products.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 400,
                    child: state.searchQuery.isNotEmpty
                        ? SearchEmptyState(
                            query: state.searchQuery,
                            onClear: () {
                              _searchController.clear();
                              context.read<ProductBloc>().add(
                                const ProductSearchChanged(''),
                              );
                            },
                          )
                        : state.categoryFilter != null
                        ? AppEmptyState(
                            icon: Icons.filter_list_off,
                            title: ctx.l10n.noProductsInCategory,
                            actionLabel: ctx.l10n.clearFilters,
                            onAction: () {
                              context.read<ProductBloc>().add(
                                const ProductCategoryFilterChanged(null),
                              );
                            },
                          )
                        : AppEmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: ctx.l10n.noProducts,
                            message: ctx.l10n.tapProductToAdd,
                          ),
                  ),
                )
              else if (state.searchQuery.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => SearchResultTile(
                      product: products[i],
                      query: state.searchQuery,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        final allowOversell = context
                            .read<SettingsCubit>()
                            .state
                            .settings
                            .allowOversell;
                        context.read<CartBloc>().add(
                          CartProductAdded(
                            products[i],
                            allowOversell: allowOversell,
                          ),
                        );
                        AppSnackBar.info(
                          context,
                          context.l10n.productAddedToCart(products[i].name),
                        );
                      },
                    ),
                  ),
                )
              else
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.crossAxisExtent >= 720;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isWide ? 220 : 186,
                        mainAxisExtent: isWide ? 160 : 148,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) => SaleProductCard(
                          product: products[index],
                          currency: currency,
                        ),
                        childCount: products.length,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
