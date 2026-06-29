import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_result_tile.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_sliver_content.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/category_filter_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_dashboard_header.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_filter_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_product_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleCatalog extends StatelessWidget {
  const SaleCatalog({
    super.key,
    required this.searchController,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onClearFilters,
  });

  final TextEditingController searchController;
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onViewModeChanged;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (_, state) {
        if (searchController.text != state.searchQuery) {
          searchController.text = state.searchQuery;
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
          final products = activeProducts;

          return CustomScrollView(
            slivers: [
              if (state.searchQuery.isEmpty)
                const SliverToBoxAdapter(child: SaleDashboardHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: SaleFilterBar(productState: state),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: _buildCategoryButton(ctx, state),
                      ),
                      const SizedBox(width: 6),
                      SegmentedButton<ViewMode>(
                        segments: const [
                          ButtonSegment(
                            value: ViewMode.list,
                            icon: Icon(Icons.view_list, size: 18),
                          ),
                          ButtonSegment(
                            value: ViewMode.grid,
                            icon: Icon(Icons.grid_view, size: 18),
                          ),
                        ],
                        selected: {viewMode},
                        onSelectionChanged: (selection) =>
                            onViewModeChanged(selection.first),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                      ),
                    ],
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
                              searchController.clear();
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
                            onAction: onClearFilters,
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
              else if (viewMode == ViewMode.list)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 80),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (_, i) => SizedBox(
                      height: 88,
                      child: SaleProductCard(
                        product: products[i],
                        currency: currency,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisExtent: 240,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
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

  Widget _buildCategoryButton(BuildContext context, ProductState state) {
    final l10n = context.l10n;
    final categories = context.watch<CategoryBloc>().state.categories;
    final selected = state.categoryFilter;

    String label;
    if (selected == null) {
      label = l10n.filterCategory;
    } else if (selected == kNoCategoryFilter) {
      label = l10n.noCategory;
    } else {
      label =
          categories
              .where((c) => c.id == selected)
              .map((c) => c.name)
              .firstOrNull ??
          l10n.filterCategory;
    }

    final hasSelection = selected != null;

    return PillButton(
      icon: Icons.category_outlined,
      label: label,
      active: hasSelection,
      onTap: () => CategoryFilterSheet.show(context),
      onClear: hasSelection
          ? () => context.read<ProductBloc>().add(
              const ProductCategoryFilterChanged(null),
            )
          : null,
    );
  }
}
