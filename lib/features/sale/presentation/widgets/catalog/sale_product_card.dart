import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_cue.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_card_shell.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_indicator.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/utils/sale_add_to_cart.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleProductCard extends StatelessWidget {
  const SaleProductCard({
    super.key,
    required this.product,
    required this.currency,
    this.isGrid = false,
  });

  final Product product;
  final String currency;
  final bool isGrid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final cartQty = context.select<CartBloc, int>(
      (bloc) => bloc.state.items
          .where((item) => item.product.id == product.id)
          .fold(0, (sum, item) => sum + item.qty),
    );
    final outOfStock = product.trackStock && product.stock == 0;
    final allowOversell = context.select(
      (SettingsCubit c) => c.state.settings.allowOversell,
    );
    final canTap = !outOfStock || allowOversell;
    final lowStockThreshold = context.select(
      (SettingsCubit c) => c.state.settings.lowStockThreshold,
    );
    final inCart = cartQty > 0;
    final radius = pos.productCardRadius;

    void onAdd() => saleAddToCart(context, product);

    return BlocSelector<CategoryBloc, CategoryState, Category?>(
      selector: (state) =>
          state.categories.where((c) => c.id == product.categoryId).firstOrNull,
      builder: (context, category) {
        if (isGrid) {
          return _buildGrid(
            context: context,
            theme: theme,
            pos: pos,
            category: category,
            cartQty: cartQty,
            outOfStock: outOfStock,
            allowOversell: allowOversell,
            canTap: canTap,
            lowStockThreshold: lowStockThreshold,
            inCart: inCart,
            radius: radius,
            onAdd: onAdd,
          );
        }
        return _buildList(
          context: context,
          theme: theme,
          pos: pos,
          category: category,
          cartQty: cartQty,
          outOfStock: outOfStock,
          allowOversell: allowOversell,
          canTap: canTap,
          lowStockThreshold: lowStockThreshold,
          inCart: inCart,
          radius: radius,
          onAdd: onAdd,
        );
      },
    );
  }

  Widget _buildGrid({
    required BuildContext context,
    required ThemeData theme,
    required PosThemeExtension pos,
    required Category? category,
    required int cartQty,
    required bool outOfStock,
    required bool allowOversell,
    required bool canTap,
    required int lowStockThreshold,
    required bool inCart,
    required double radius,
    required VoidCallback onAdd,
  }) {
    return RepaintBoundary(
      child: _OosWrapper(
        outOfStock: outOfStock && !allowOversell,
        child: ProductCardShell(
          onTap: canTap ? onAdd : null,
          onLongPress: canTap
              ? () => saleAddToCartWithQtyDialog(
                  context,
                  product,
                  currentCartQty: cartQty,
                )
              : null,
          borderRadius: radius,
          borderColor: inCart ? pos.selectedProductBorder : null,
          elevation: inCart ? 2 : 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1.5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductAvatar(
                      imagePath: product.imagePath,
                      imageThumbnailPath: product.imageThumbnailPath,
                      imageUrl: product.imageUrl,
                      size: 200,
                      shape: BoxShape.rectangle,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                    if (product.isRecommended)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                color: theme.colorScheme.shadow.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            size: 21,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                    if (inCart)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _CartQtyBadge(qty: cartQty, pos: pos),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  // Tighter body so meta + stock + add fit mainAxisExtent 200.
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        // Meta steals a line inside fixed mainAxisExtent.
                        maxLines: _hasMeta(product, category) ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.2,
                        ),
                      ),
                      if (_hasMeta(product, category)) ...[
                        const SizedBox(height: 2),
                        _MetaLine(
                          product: product,
                          category: category,
                          compact: true,
                        ),
                      ],
                      const SizedBox(height: 4),
                      // Stack footer: stock on its own line so price+add
                      // never fight for width on narrow grid cells.
                      MoneyText(
                        value: product.price.value,
                        currency: currency,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          height: 1.0,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -3),
                        child: Row(
                          children: [
                            Expanded(
                              child: StockIndicator(
                                stock: product.stock,
                                trackStock: product.trackStock,
                                compact: true,
                                lowStockThreshold: lowStockThreshold,
                                showStockLabel: true,
                              ),
                            ),
                            if (canTap) ...[
                              const SizedBox(width: 4),
                              _AddButton(onPressed: onAdd, compact: true),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList({
    required BuildContext context,
    required ThemeData theme,
    required PosThemeExtension pos,
    required Category? category,
    required int cartQty,
    required bool outOfStock,
    required bool allowOversell,
    required bool canTap,
    required int lowStockThreshold,
    required bool inCart,
    required double radius,
    required VoidCallback onAdd,
  }) {
    final l10n = context.l10n;
    final isLow =
        product.trackStock &&
        product.stock > 0 &&
        product.stock <= (lowStockThreshold < 1 ? 1 : lowStockThreshold);

    return RepaintBoundary(
      child: _OosWrapper(
        outOfStock: outOfStock && !allowOversell,
        child: ProductCardShell(
          onTap: canTap ? onAdd : null,
          onLongPress: canTap
              ? () => saleAddToCartWithQtyDialog(
                  context,
                  product,
                  currentCartQty: cartQty,
                )
              : null,
          borderRadius: radius,
          borderColor: inCart ? pos.selectedProductBorder : null,
          elevation: inCart ? 2 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProductAvatar(
                      imagePath: product.imagePath,
                      imageThumbnailPath: product.imageThumbnailPath,
                      imageUrl: product.imageUrl,
                      size: 60,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    if (inCart)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: _CartQtyBadge(qty: cartQty, pos: pos),
                      ),
                  ],
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
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (product.isRecommended)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: theme.colorScheme.tertiary,
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
                      const SizedBox(height: 6),
                      if (category != null &&
                          (product.sku == null || product.sku!.isEmpty))
                        CategoryCue(
                          category: category,
                          style: CategoryCueStyle.pill,
                        ),
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
                      MoneyText(
                        value: product.price.value,
                        currency: currency,
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
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${CurrencyFormatter.formatQuantityCompact(product.stock)} ${l10n.piecesLabel}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: product.stock == 0
                                                  ? theme.colorScheme.error
                                                  : isLow
                                                  ? theme.colorScheme.tertiary
                                                  : theme.colorScheme.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
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
                    ],
                  ),
                ),
                // Popup menu: add / qty
                PopupMenuButton<String>(
                  tooltip: l10n.productRowMenu,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: Icon(
                    Icons.more_vert,
                    size: 24,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (!canTap) return;
                    if (value == 'add') {
                      onAdd();
                    } else if (value == 'qty') {
                      saleAddToCartWithQtyDialog(
                        context,
                        product,
                        currentCartQty: cartQty,
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'add',
                      enabled: canTap,
                      child: Text(l10n.productRowMenuAdd),
                    ),
                    PopupMenuItem(
                      value: 'qty',
                      enabled: canTap,
                      child: Text(l10n.productRowMenuQty),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool _hasMeta(Product product, Category? category) {
  final sku = product.sku?.trim() ?? '';
  if (sku.isNotEmpty) return true;
  return category != null;
}

/// One secondary line: SKU if present, else category cue. Never both.
class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.product,
    required this.category,
    this.compact = false,
  });

  final Product product;
  final Category? category;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sku = product.sku?.trim() ?? '';
    if (sku.isNotEmpty) {
      return Text(
        '${context.l10n.skuLabel}: $sku',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (category != null) {
      return CategoryCue(
        category: category!,
        style: CategoryCueStyle.label,
        compact: compact,
      );
    }
    return const SizedBox.shrink();
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed, this.compact = false});

  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // List row budget ~92 tall; keep a large disc without overflowing.
    final hit = compact ? 32.0 : 36.0;
    return Semantics(
      button: true,
      label: context.l10n.addToCart,
      child: Material(
        color: theme.colorScheme.primary,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: hit,
            height: hit,
            child: Center(
              child: Icon(
                Icons.add,
                size: compact ? 20 : 22,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartQtyBadge extends StatelessWidget {
  const _CartQtyBadge({required this.qty, required this.pos});

  final int qty;
  final PosThemeExtension pos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: pos.qtyBadgeBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: pos.selectedProductBorder, width: 1),
      ),
      child: Text(
        '×$qty',
        style: TextStyle(
          color: pos.qtyBadgeForeground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFamily: 'NotoSansThai',
        ),
      ),
    );
  }
}

/// Wraps a product card with grayscale + "Out of Stock" badge when OOS.
/// Replaces the old Opacity(0.55) approach with clearer visual feedback.
class _OosWrapper extends StatelessWidget {
  const _OosWrapper({required this.outOfStock, required this.child});
  final bool outOfStock;
  final Widget child;

  static const _grayMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    if (!outOfStock) return child;
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grayMatrix),
          child: child,
        ),
        // "Out of Stock" badge — top-center, prominent.
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: cs.shadow.withValues(alpha: 0.2),
                  ),
                ],
              ),
              child: Text(
                context.l10n.outOfStock,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
