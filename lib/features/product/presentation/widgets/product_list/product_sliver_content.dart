import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/modern_product_grid_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/modern_product_tile.dart';

enum ViewMode { list, grid }

class ProductSliverContent extends StatelessWidget {
  const ProductSliverContent({
    super.key,
    required this.status,
    required this.products,
    required this.allProducts,
    required this.searchQuery,
    required this.viewMode,
    required this.searchController,
    required this.onClearFilters,
  });

  final ProductStatus status;
  final List<Product> products;
  final List<Product> allProducts;
  final String searchQuery;
  final ViewMode viewMode;
  final TextEditingController searchController;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (status == ProductStatus.loading || status == ProductStatus.initial) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (status == ProductStatus.failure) {
      return SliverFillRemaining(
        child: AppEmptyState(
          icon: Icons.error_outline,
          title: context.l10n.errorOccurred,
        ),
      );
    }
    if (products.isEmpty) {
      if (allProducts.isEmpty) {
        return SliverFillRemaining(
          child: AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: context.l10n.noProductsYet,
          ),
        );
      }
      return SliverFillRemaining(
        child: AppEmptyState(
          icon: searchQuery.isNotEmpty
              ? Icons.search_off
              : Icons.filter_list_off,
          title: searchQuery.isNotEmpty
              ? context.l10n.noSearchResults
              : context.l10n.noProductsInCategory,
          actionLabel: context.l10n.clearFilters,
          onAction: onClearFilters,
        ),
      );
    }
    return viewMode == ViewMode.list
        ? SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            sliver: SliverList.separated(
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => ModernProductTile(product: products[i]),
            ),
          )
        : SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.80,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => ModernProductGridCard(product: products[i]),
                childCount: products.length,
              ),
            ),
          );
  }
}
