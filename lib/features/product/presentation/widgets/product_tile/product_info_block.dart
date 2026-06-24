import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/category_style_resolver.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_indicator.dart';

class ProductInfoBlock extends StatelessWidget {
  const ProductInfoBlock({
    super.key,
    required this.product,
    required this.currency,
    this.categoryName,
    this.layout = ProductInfoLayout.row,
    this.onNameTap,
    this.onPriceTap,
    this.onStockTap,
  });

  final Product product;
  final String currency;
  final String? categoryName;
  final ProductInfoLayout layout;
  final VoidCallback? onNameTap;
  final VoidCallback? onPriceTap;
  final VoidCallback? onStockTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catStyle = categoryName != null
        ? CategoryStyleResolver.resolve(categoryName!)
        : null;

    final nameWidget = InkWell(
      onTap: onNameTap,
      borderRadius: BorderRadius.circular(4),
      child: Text(
        product.name,
        maxLines: layout == ProductInfoLayout.grid ? 2 : 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: layout == ProductInfoLayout.grid ? 14 : 16,
          color: onNameTap != null ? theme.colorScheme.primary : null,
        ),
      ),
    );

    final categoryChip = categoryName != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: catStyle?.color == Colors.transparent
                      ? theme.colorScheme.primary
                      : catStyle!.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                categoryName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        : null;

    final skuWidget = (product.sku != null && product.sku!.isNotEmpty)
        ? Text(
            'SKU: ${product.sku}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        : null;

    final stockPriceRow = Row(
      children: [
        InkWell(
          onTap: onStockTap,
          borderRadius: BorderRadius.circular(8),
          child: StockIndicator(
            stock: product.stock,
            trackStock: product.trackStock,
            compact: true,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: layout == ProductInfoLayout.grid
                ? theme.colorScheme.surfaceContainerHighest
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: onPriceTap,
            borderRadius: BorderRadius.circular(6),
            child: MoneyText(
              value: product.price,
              currency: currency,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: layout == ProductInfoLayout.grid ? 15 : 15,
              ),
              color: layout == ProductInfoLayout.grid
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );

    if (layout == ProductInfoLayout.grid) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          nameWidget,
          const SizedBox(height: 6),
          if (categoryChip != null) ...[
            categoryChip,
            const SizedBox(height: 4),
          ],
          if (skuWidget != null) ...[skuWidget, const SizedBox(height: 4)],
          stockPriceRow,
        ],
      );
    }

    if (layout == ProductInfoLayout.compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onNameTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onPriceTap,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: MoneyText(
                    value: product.price,
                    currency: currency,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (categoryChip != null) Flexible(child: categoryChip),
              const Spacer(),
              InkWell(
                onTap: onStockTap,
                borderRadius: BorderRadius.circular(8),
                child: StockIndicator(
                  stock: product.stock,
                  trackStock: product.trackStock,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      );
    }

    // list layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        nameWidget,
        const SizedBox(height: 6),
        Row(
          children: [
            if (categoryChip != null) ...[Flexible(child: categoryChip)],
            if (skuWidget != null && categoryChip != null)
              Text(
                ' \u2022 ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            if (skuWidget != null) ...[Flexible(child: skuWidget)],
          ],
        ),
        const SizedBox(height: 10),
        stockPriceRow,
      ],
    );
  }
}

enum ProductInfoLayout { row, grid, compact }
