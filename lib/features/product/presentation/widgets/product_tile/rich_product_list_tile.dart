import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_list_tile.dart'
    show parseCategoryColor;
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_icon_data.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/product_action_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shimmer/shimmer.dart';

String _compactNumber(num value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return m >= 100 ? '${m.toStringAsFixed(0)}M' : '${m.toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return k >= 100 ? '${k.toStringAsFixed(0)}K' : '${k.toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(2);
}

class RichProductListTile extends StatelessWidget {
  const RichProductListTile({
    super.key,
    required this.product,
    this.isLoading = false,
  });

  final Product product;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final lowStockThreshold = settings.lowStockThreshold;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isLow =
        product.trackStock &&
        product.stock > 0 &&
        product.stock <= (lowStockThreshold < 1 ? 1 : lowStockThreshold);

    return RepaintBoundary(
      child: Dismissible(
        key: ValueKey(product.id),
        direction: DismissDirection.endToStart,
        background: const DeleteBackground(),
        confirmDismiss: (_) => confirmDeleteProduct(context, product),
        child: BlocSelector<CategoryBloc, CategoryState, Category?>(
          selector: (state) => state.categories
              .where((c) => c.id == product.categoryId)
              .firstOrNull,
          builder: (_, cat) {
            if (isLoading) {
              return _SkeletonTile(theme: theme);
            }
            final content = Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => showProductPreviewPage(context, product),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProductAvatar(
                          imagePath: product.imagePath,
                          imageThumbnailPath: product.imageThumbnailPath,
                          imageUrl: product.imageUrl,
                          size: 60,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(width: 10),
                        // Left column: name, SKU, barcode, category
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ),
                                  if (product.isRecommended && product.isActive)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.star_rounded,
                                        size: 18,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.sku != null && product.sku!.isNotEmpty
                                    ? '${l10n.skuLabel}: ${product.sku}'
                                    : '${l10n.skuLabel}: ${l10n.na}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.barcode != null &&
                                        product.barcode!.isNotEmpty
                                    ? '${l10n.barcodeLabel}: ${product.barcode}'
                                    : '${l10n.barcodeLabel}: ${l10n.na}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (cat != null) _CategoryPill(category: cat),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Right column: price, stock, cost
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$currency${_compactNumber(product.price.value)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (product.trackStock)
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (product.stock == 0)
                                        Icon(
                                          Icons.error_outline,
                                          size: 12,
                                          color: theme.colorScheme.error,
                                        )
                                      else if (isLow)
                                        Icon(
                                          Icons.warning_amber,
                                          size: 12,
                                          color: theme.colorScheme.tertiary,
                                        ),
                                      if (product.stock == 0 || isLow)
                                        const SizedBox(width: 2),
                                      Flexible(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: '${l10n.stockOnHand} ',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              TextSpan(
                                                text:
                                                    '${CurrencyFormatter.formatQuantityCompact(product.stock)} ${l10n.piecesLabel}',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      color: product.stock == 0
                                                          ? theme
                                                                .colorScheme
                                                                .error
                                                          : isLow
                                                          ? theme
                                                                .colorScheme
                                                                .tertiary
                                                          : theme
                                                                .colorScheme
                                                                .primary,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  l10n.stockNotTracked,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.productPreviewCost} $currency${_compactNumber(product.cost.value)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Menu button — far right, vertically centered
                        IconButton(
                          onPressed: () =>
                              showProductActionSheet(context, product),
                          icon: Icon(
                            Icons.more_vert,
                            size: 24,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          padding: const EdgeInsets.all(2),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );

            if (!product.isActive) {
              return Opacity(opacity: 0.55, child: content);
            }
            return content;
          },
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: cs.surfaceContainerHighest,
        highlightColor: cs.surfaceContainerLow,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar skeleton
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 10),
            // Left column skeleton
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 11,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 11,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // Right column skeleton
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 70,
                    height: 16,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 11,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 70,
                    height: 11,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Menu placeholder
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
