import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/errors/app_error_display.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/search_surface_config.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/open_bills_strip.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog_filter_chrome.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_mode_switcher.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_product_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleCatalog extends StatefulWidget {
  const SaleCatalog({
    super.key,
    required this.searchController,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onClearFilters,
    this.bottomContentInset = 0,
  });

  final TextEditingController searchController;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final VoidCallback onClearFilters;
  final double bottomContentInset;

  @override
  State<SaleCatalog> createState() => _SaleCatalogState();
}

class _SaleCatalogState extends State<SaleCatalog> {
  bool _recommendedOnly = false;

  List<Product> _prepareProducts(List<Product> active) {
    if (_recommendedOnly) {
      return active.where((p) => p.isRecommended).toList();
    }
    final boosted = <Product>[];
    final rest = <Product>[];
    for (final p in active) {
      if (p.isRecommended) {
        boosted.add(p);
      } else {
        rest.add(p);
      }
    }
    return [...boosted, ...rest];
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final threshold = settings.lowStockThreshold;
    // Must use State.build context for select/watch — not BlocBuilder's parent
    // Element when that Element is not the one currently building.
    final categories = context.select<CategoryBloc, List<Category>>(
      (b) => b.state.categories,
    );
    // Multi-bill chrome only when 2+ non-empty bills (density / wireframe).
    // Must use State.build context — not BlocBuilder's builder context.
    final openBillCount = context.select<DraftBloc, int>(
      (b) => b.state.openBillCount,
    );

    ProductBloc productBloc;
    try {
      productBloc = context.read<ProductBloc>();
    } catch (_) {
      productBloc = sl<ProductBloc>();
    }

    return BlocListener<ProductBloc, ProductState>(
      bloc: productBloc,
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (_, state) {
        if (widget.searchController.text != state.searchQuery) {
          widget.searchController.text = state.searchQuery;
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        bloc: productBloc,
        builder: (ctx, state) {
          if (state.status == ProductStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProductStatus.failure) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title:
                  state.error?.displayMessage(ctx.l10n) ??
                  ctx.l10n.errorOccurred,
            );
          }

          final activeProducts = state
              .filteredProducts(
                lowStockThreshold: threshold,
                pauseFiltersOnSearch:
                    SearchSurfaceConfig.saleListFiltered.pauseFiltersOnSearch,
              )
              .where((product) => product.isActive)
              .toList();
          final hasRecommended = activeProducts.any((p) => p.isRecommended);
          if (_recommendedOnly && !hasRecommended && mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _recommendedOnly) {
                setState(() => _recommendedOnly = false);
              }
            });
          }
          final products = _prepareProducts(activeProducts);
          final terminalInset = 12 + widget.bottomContentInset;
          final isUltra = settings.ultraCompactMode;
          final showMultiBillChrome = !isUltra && openBillCount > 1;

          return CustomScrollView(
            slivers: [
              if (showMultiBillChrome)
                const SliverToBoxAdapter(child: SaleModeSwitcher()),
              if (showMultiBillChrome)
                const SliverToBoxAdapter(child: OpenBillsStrip()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SaleCatalogFilterChrome(
                    categories: categories,
                    productState: state,
                    viewMode: widget.viewMode,
                    onViewModeChanged: widget.onViewModeChanged,
                    showCategories: state.searchQuery.isEmpty,
                    hasRecommended: state.searchQuery.isEmpty && hasRecommended,
                    recommendedOnly: _recommendedOnly,
                    onRecommendedChanged: (v) =>
                        setState(() => _recommendedOnly = v),
                    onCategorySelected: (id) {
                      context.read<ProductBloc>().add(
                        ProductCategoryFilterChanged(id),
                      );
                    },
                  ),
                ),
              ),
              if (products.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.5,
                    child: state.searchQuery.isNotEmpty
                        ? SearchEmptyState(
                            query: state.searchQuery,
                            onClear: () {
                              widget.searchController.clear();
                              context.read<ProductBloc>().add(
                                const ProductSearchChanged(''),
                              );
                            },
                          )
                        : _recommendedOnly
                        ? AppEmptyState(
                            icon: Icons.star_outline,
                            title: context.l10n.saleRecommendedFilter,
                            actionLabel: context.l10n.saleRecommendedFilterAll,
                            onAction: () =>
                                setState(() => _recommendedOnly = false),
                          )
                        : state.categoryFilter != null
                        ? AppEmptyState(
                            icon: Icons.filter_list_off,
                            title: ctx.l10n.noProductsInCategory,
                            actionLabel: ctx.l10n.clearFilters,
                            onAction: widget.onClearFilters,
                          )
                        : AppEmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: ctx.l10n.noProducts,
                            message: ctx.l10n.tapProductToAdd,
                          ),
                  ),
                )
              else if (state.searchQuery.isNotEmpty ||
                  widget.viewMode == ViewMode.list)
                SliverPadding(
                  padding: EdgeInsets.only(bottom: terminalInset),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    // 92: room for name + 1 meta line + stock + price/add
                    // without bottom RenderFlex overflow on device text scale.
                    itemBuilder: (_, i) => SizedBox(
                      height: 92,
                      child: SaleProductCard(
                        product: products[i],
                        currency: currency,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.only(bottom: terminalInset),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 168,
                          // Image 88 + body (name/meta/stock/price+add).
                          mainAxisExtent: 200,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => SaleProductCard(
                        product: products[index],
                        currency: currency,
                        isGrid: true,
                      ),
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
