import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_list_paging.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
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
    this.viewMode = ViewMode.list,
    this.onImport,
    this.onAddProduct,
    this.onRetry,
  });

  final ProductStatus status;
  final List<Product> products;
  final int displayCount;
  final List<Product> allProducts;
  final String searchQuery;
  final TextEditingController searchController;
  final VoidCallback onClearFilters;
  final bool hasMore;
  final ViewMode viewMode;
  final VoidCallback? onImport;
  final VoidCallback? onAddProduct;
  final VoidCallback? onRetry;

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
          actionLabel: context.l10n.retry,
          onAction: onRetry,
        ),
      );
    }
    if (products.isEmpty) {
      if (allProducts.isEmpty) {
        return SliverFillRemaining(
          child: SingleChildScrollView(
            child: AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.noProductsYet,
              message: context.l10n.noProductsYetHint,
              actionLabel: context.l10n.addProduct,
              onAction: onAddProduct,
              secondaryActionLabel: onImport != null
                  ? context.l10n.importProducts
                  : null,
              onSecondaryAction: onImport,
            ),
          ),
        );
      }
      return SliverFillRemaining(
        child: SingleChildScrollView(
          child: AppEmptyState(
            icon: searchQuery.isNotEmpty
                ? Icons.search_off
                : Icons.filter_list_off,
            title: searchQuery.isNotEmpty
                ? context.l10n.noSearchResults
                : context.l10n.noProductsInCategory,
            message: searchQuery.isNotEmpty
                ? context.l10n.noSearchResultsHint
                : null,
            actionLabel: context.l10n.clearFilters,
            onAction: onClearFilters,
          ),
        ),
      );
    }
    final visibleProducts = products.take(displayCount).toList();
    if (viewMode == ViewMode.grid) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            // Adaptive: larger tiles on tablets for better use of space.
            maxCrossAxisExtent: MediaQuery.of(context).size.width >= 600
                ? 220
                : 180,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate((ctx, i) {
            if (i >= visibleProducts.length) {
              return Center(
                child: Semantics(
                  label: 'Loading more products',
                  liveRegion: true,
                  child: const CircularProgressIndicator(strokeWidth: 2.5),
                ),
              );
            }
            return _ProductGridTile(product: visibleProducts[i]);
          }, childCount: visibleProducts.length + (hasMore ? 1 : 0)),
        ),
      );
    }
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

/// Compact grid tile for grid view mode.
class _ProductGridTile extends StatelessWidget {
  const _ProductGridTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: product.imageThumbnailPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageThumbnailPath!,
                          fit: BoxFit.cover,
                          semanticLabel: product.name,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.inventory_2_outlined,
                            size: 40,
                            color: cs.outline,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_outlined,
                        size: 40,
                        color: cs.outline,
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (product.sku != null && product.sku!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                product.sku!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.price.value.toStringAsFixed(2),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (product.trackStock) _GridStockDot(product: product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact stock indicator dot for grid tiles — green/yellow/red.
class _GridStockDot extends StatelessWidget {
  const _GridStockDot({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color color;
    if (product.stock == 0) {
      color = cs.error;
    } else if (product.stock <= 5) {
      color = cs.tertiary;
    } else {
      color = cs.primary;
    }
    return Tooltip(
      message: '${product.stock} in stock',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
