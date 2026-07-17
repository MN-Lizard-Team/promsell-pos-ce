import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
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
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    final canTap = !outOfStock || allowOversell;
    final lowStockThreshold = context
        .read<SettingsCubit>()
        .state
        .settings
        .lowStockThreshold;
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
      child: Opacity(
        opacity: outOfStock && !allowOversell ? 0.55 : 1.0,
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
              SizedBox(
                height: 88,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductAvatar(
                      imagePath: product.imagePath,
                      imageThumbnailPath: product.imageThumbnailPath,
                      imageUrl: product.imageUrl,
                      size: 200,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(radius),
                      ),
                    ),
                    if (product.isRecommended)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: theme.colorScheme.tertiary,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: theme.colorScheme.shadow.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (inCart)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _CartQtyBadge(qty: cartQty, pos: pos),
                      ),
                    if (outOfStock)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: _OutOfStockChip(theme: theme),
                      ),
                    if (category != null &&
                        (product.sku == null || product.sku!.isEmpty))
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: CategoryCue(
                          category: category,
                          style: CategoryCueStyle.dot,
                          compact: true,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  // Tighter body so meta + stock + add fit mainAxisExtent 200.
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        // Meta steals a line inside fixed mainAxisExtent.
                        maxLines: _hasMeta(product, category) ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.15,
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
                      const Spacer(),
                      // Stack footer: stock on its own line so price+add
                      // never fight for width on narrow grid cells.
                      StockIndicator(
                        stock: product.stock,
                        trackStock: product.trackStock,
                        compact: true,
                        lowStockThreshold: lowStockThreshold,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: MoneyText(
                              value: product.price.value,
                              currency: currency,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          if (canTap) ...[
                            const SizedBox(width: 4),
                            _AddButton(onPressed: onAdd, compact: true),
                          ],
                        ],
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
    final hasMeta = _hasMeta(product, category);
    // Catalog list row is fixed height — one name line when meta is present.
    final nameMaxLines = hasMeta ? 1 : 2;

    return RepaintBoundary(
      child: Opacity(
        opacity: outOfStock && !allowOversell ? 0.55 : 1.0,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                      size: 56,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    if (inCart)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: _CartQtyBadge(qty: cartQty, pos: pos),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: nameMaxLines,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (product.isRecommended)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                        ],
                      ),
                      if (hasMeta) ...[
                        const SizedBox(height: 2),
                        _MetaLine(product: product, category: category),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: StockIndicator(
                                    stock: product.stock,
                                    trackStock: product.trackStock,
                                    compact: true,
                                    lowStockThreshold: lowStockThreshold,
                                  ),
                                ),
                                if (outOfStock) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    context.l10n.outOfStock,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          MoneyText(
                            value: product.price.value,
                            currency: currency,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              height: 1.1,
                            ),
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Wireframe trailing: hamburger menu (≡), not + button.
                PopupMenuButton<String>(
                  tooltip: context.l10n.productRowMenu,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: Icon(
                    Icons.menu,
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
                      child: Text(context.l10n.productRowMenuAdd),
                    ),
                    PopupMenuItem(
                      value: 'qty',
                      enabled: canTap,
                      child: Text(context.l10n.productRowMenuQty),
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
        color: theme.colorScheme.primaryContainer,
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
                color: theme.colorScheme.onPrimaryContainer,
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

class _OutOfStockChip extends StatelessWidget {
  const _OutOfStockChip({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.outOfStock,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
