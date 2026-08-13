import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_highlight_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_card_shell.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_badge.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SearchResultTile extends StatefulWidget {
  const SearchResultTile({
    super.key,
    required this.product,
    required this.query,
    this.matchType,
    this.matchField,
    this.onTap,
    this.onLongPress,
    this.cartQty = 0,
    this.showAddAffordance = false,
  });

  final Product product;
  final String query;

  /// Localized label for chip (e.g. ชื่อ / SKU).
  final String? matchType;

  /// Which field matched: `name` | `sku` | `barcode`.
  final String? matchField;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// When > 0, shows an in-cart qty badge (Sale POS search).
  final int cartQty;

  /// When true, trailing chevron is replaced with an add affordance
  /// and chrome aligns closer to [SaleProductCard] list.
  final bool showAddAffordance;

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.97);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final saleChrome = widget.showAddAffordance;
    final inCart = widget.cartQty > 0;

    final body = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: saleChrome ? 12 : 16,
        vertical: saleChrome ? 10 : 12,
      ),
      child: Row(
        children: [
          _LeadingAvatar(
            product: widget.product,
            saleChrome: saleChrome,
            cartQty: widget.cartQty,
          ),
          SizedBox(width: saleChrome ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchHighlightText(
                  text: widget.product.name,
                  query:
                      widget.matchField == 'name' || widget.matchField == null
                      ? widget.query
                      : '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: saleChrome ? 15 : 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _SubtitleRow(
                  product: widget.product,
                  query: widget.query,
                  matchField: widget.matchField,
                ),
                if (widget.matchType != null) ...[
                  const SizedBox(height: 4),
                  _MatchChip(label: widget.matchType!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MoneyText(
                value: widget.product.price.value,
                currency: currency,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 4),
              // Sale chrome: cart qty lives on avatar; show stock under price.
              if (!saleChrome && inCart)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '×${widget.cartQty}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              else if (!saleChrome)
                StockBadge(stock: widget.product.stock),
              // In sale chrome, always show stock (even when in cart).
              if (saleChrome) StockBadge(stock: widget.product.stock),
            ],
          ),
          const SizedBox(width: 8),
          if (saleChrome)
            _SaleAddDisc(theme: theme)
          else
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.secondary,
              size: 24,
            ),
        ],
      ),
    );

    if (saleChrome) {
      // Shell owns the ink/tap target (matches SaleProductCard list).
      return ProductCardShell(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        borderRadius: 16,
        borderColor: inCart ? theme.colorScheme.primary : null,
        elevation: inCart ? 2 : 0.5,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: body,
      );
    }

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: body,
        ),
      ),
    );
  }
}

class _LeadingAvatar extends StatelessWidget {
  const _LeadingAvatar({
    required this.product,
    required this.saleChrome,
    required this.cartQty,
  });

  final Product product;
  final bool saleChrome;
  final int cartQty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatar = ProductAvatar(
      imagePath: product.imagePath,
      imageThumbnailPath: product.imageThumbnailPath,
      imageUrl: product.imageUrl,
      size: saleChrome ? 56 : 48,
      shape: saleChrome ? BoxShape.rectangle : BoxShape.circle,
      borderRadius: saleChrome ? BorderRadius.circular(12) : null,
    );

    if (!saleChrome || cartQty <= 0) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.colorScheme.primary, width: 1),
            ),
            child: Text(
              '×$cartQty',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaleAddDisc extends StatelessWidget {
  const _SaleAddDisc({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.primaryContainer,
      shape: const CircleBorder(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          Icons.add,
          size: 22,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _SubtitleRow extends StatelessWidget {
  const _SubtitleRow({required this.product, this.query = '', this.matchField});
  final Product product;
  final String query;
  final String? matchField;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.secondary,
    );

    Widget line(String text, {required bool highlight}) {
      if (highlight && query.trim().isNotEmpty) {
        return SearchHighlightText(
          text: text,
          query: query,
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final skuLabel = context.l10n.skuLabel;
    String skuPart(String sku) => '$skuLabel: $sku';

    // Prefer category name when available; always show SKU if present.
    return BlocBuilder<CategoryBloc, CategoryState>(
      buildWhen: (p, c) => p.categories != c.categories,
      builder: (context, catState) {
        final catName = product.categoryId == null
            ? null
            : catState.categories
                  .where((c) => c.id == product.categoryId)
                  .map((c) => c.name)
                  .firstOrNull;

        final parts = <Widget>[];
        if (catName != null && catName.isNotEmpty) {
          parts.add(line(catName, highlight: false));
        }
        final sku = product.sku?.trim() ?? '';
        if (sku.isNotEmpty) {
          parts.add(line(skuPart(sku), highlight: matchField == 'sku'));
        }
        final barcode = product.barcode?.trim() ?? '';
        if (matchField == 'barcode' && barcode.isNotEmpty) {
          parts.add(line(barcode, highlight: true));
        }

        if (parts.isEmpty) {
          return Text(context.l10n.na, maxLines: 1, style: style);
        }

        return Row(
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              if (i > 0) Text(' · ', style: style),
              Flexible(child: parts[i]),
            ],
          ],
        );
      },
    );
  }
}

class _MatchChip extends StatelessWidget {
  const _MatchChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
