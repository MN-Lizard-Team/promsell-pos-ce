import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_list_paging.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/rich_product_list_tile.dart';

class ProductSliverContent extends StatelessWidget {
  const ProductSliverContent({
    super.key,
    required this.status,
    required this.products,
    required this.displayCount,
    required this.allProducts,
    required this.searchQuery,
    required this.searchController,
    required this.onClearFilters,
    required this.hasMore,
    this.onImport,
  });

  final ProductStatus status;
  final List<Product> products;
  final int displayCount;
  final List<Product> allProducts;
  final String searchQuery;
  final TextEditingController searchController;
  final VoidCallback onClearFilters;
  final bool hasMore;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    if (status == ProductStatus.loading || status == ProductStatus.initial) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
        sliver: SliverList.separated(
          itemCount: ProductListPaging.initialPageSize.clamp(1, 8),
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, _) => RichProductListTile(
            product: Product(
              id: '',
              name: '',
              price: Money.zero,
              stock: 0,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            isLoading: true,
          ),
        ),
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
            actionLabel: onImport != null ? context.l10n.importProducts : null,
            onAction: onImport,
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
    final visibleProducts = products.take(displayCount).toList();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
      sliver: SliverList.separated(
        itemCount: visibleProducts.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i >= visibleProducts.length) {
            final cs = Theme.of(context).colorScheme;
            return Padding(
              key: const ValueKey('product-list-load-more'),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: cs.primary,
                  ),
                ),
              ),
            );
          }
          return RichProductListTile(product: visibleProducts[i]);
        },
      ),
    );
  }
}
