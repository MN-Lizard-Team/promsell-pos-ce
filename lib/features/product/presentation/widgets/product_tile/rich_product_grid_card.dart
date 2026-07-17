import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_card_shell.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/product_action_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_indicator.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class RichProductGridCard extends StatelessWidget {
  const RichProductGridCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: const DeleteBackground(),
      confirmDismiss: (_) => confirmDeleteProduct(context, product),
      child: BlocSelector<CategoryBloc, CategoryState, Category?>(
        selector: (state) => state.categories
            .where((c) => c.id == product.categoryId)
            .firstOrNull,
        builder: (_, cat) {
          return ProductCardShell(
            isActive: product.isActive,
            margin: EdgeInsets.zero,
            onTap: () => showProductPreviewPage(context, product),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: ProductAvatar(
                          imagePath: product.imagePath,
                          imageThumbnailPath: product.imageThumbnailPath,
                          imageUrl: product.imageUrl,
                          size: 64,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (product.sku != null && product.sku!.isNotEmpty)
                        Text(
                          'SKU: ${product.sku}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      if (cat != null) ...[
                        const SizedBox(height: 4),
                        _CategoryPill(category: cat),
                      ],
                      const Spacer(),
                      StockIndicator(
                        stock: product.stock,
                        trackStock: product.trackStock,
                        compact: true,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MoneyText(
                            value: product.price.value,
                            currency: currency,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          if (product.trackStock && product.cost > Money.zero)
                            Text(
                              '$currency${product.cost.value.toStringAsFixed(2)}',
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
                if (product.isRecommended && product.isActive)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    onPressed: () => showProductActionSheet(context, product),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = parseCategoryColor(category.color);
    final icon = parseCategoryIcon(category.iconName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
