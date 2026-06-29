import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/image/image_skeleton.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_card_shell.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_indicator.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
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

    void onAdd() {
      HapticFeedback.selectionClick();
      context.read<CartBloc>().add(
        CartProductAdded(product, allowOversell: allowOversell),
      );
      if (cartQty == 0) {
        AppSnackBar.info(
          context,
          context.l10n.productAddedToCart(product.name),
        );
      }
    }

    if (isGrid) {
      return Opacity(
        opacity: outOfStock && !allowOversell ? 0.5 : 1.0,
        child: ProductCardShell(
          onTap: canTap ? onAdd : null,
          onLongPress: canTap
              ? () => _showQtyDialog(context, product, cartQty)
              : null,
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 120,
                child: _SaleProductImage(
                  imagePath: product.imagePath,
                  imageThumbnailPath: product.imageThumbnailPath,
                  imageUrl: product.imageUrl,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    if (cartQty > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${context.l10n.quantityLabel} $cartQty',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    StockIndicator(
                      stock: product.stock,
                      trackStock: product.trackStock,
                      compact: true,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Opacity(
      opacity: outOfStock && !allowOversell ? 0.5 : 1.0,
      child: ProductCardShell(
        onTap: canTap ? onAdd : null,
        onLongPress: canTap
            ? () => _showQtyDialog(context, product, cartQty)
            : null,
        borderRadius: 12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _SaleProductImage(
                imagePath: product.imagePath,
                imageThumbnailPath: product.imageThumbnailPath,
                imageUrl: product.imageUrl,
                width: 56,
                height: 56,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    if (cartQty > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${context.l10n.quantityLabel} $cartQty',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    StockIndicator(
                      stock: product.stock,
                      trackStock: product.trackStock,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: MoneyText(
                  value: product.price,
                  currency: currency,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQtyDialog(BuildContext context, Product product, int currentQty) {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>().state.settings;
    final allowOversell = settings.allowOversell;
    final saleBloc = context.read<CartBloc>();
    final snackCtx = context;
    showDialog(
      context: context,
      builder: (dialogCtx) => _QtyDialog(
        product: product,
        allowOversell: allowOversell,
        onSaved: (qty) {
          saleBloc.add(
            CartProductAdded(product, qty: qty, allowOversell: allowOversell),
          );
          AppSnackBar.info(snackCtx, l10n.productAddedToCart(product.name));
        },
      ),
    );
  }
}

class _SaleProductImage extends StatefulWidget {
  const _SaleProductImage({
    this.imagePath,
    this.imageThumbnailPath,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String? imagePath;
  final String? imageThumbnailPath;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<_SaleProductImage> createState() => _SaleProductImageState();
}

class _SaleProductImageState extends State<_SaleProductImage> {
  bool? _localExists;

  String? get _thumbPath => widget.imageThumbnailPath;
  String? get _fullPath => widget.imagePath;

  String? get _effectiveLocalPath {
    if (_thumbPath != null && _thumbPath!.isNotEmpty) return _thumbPath;
    if (_fullPath != null && _fullPath!.isNotEmpty) return _fullPath;
    return null;
  }

  @override
  void initState() {
    super.initState();
    _checkLocal();
  }

  @override
  void didUpdateWidget(covariant _SaleProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.imageThumbnailPath != widget.imageThumbnailPath) {
      _localExists = null;
      _checkLocal();
    }
  }

  Future<void> _checkLocal() async {
    final path = _effectiveLocalPath;
    if (path == null) {
      if (mounted) setState(() => _localExists = false);
      return;
    }
    final exists = await File(path).exists();
    if (mounted) setState(() => _localExists = exists);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.borderRadius ?? BorderRadius.circular(8);

    Widget content;

    if (_localExists == null) {
      content = ImageSkeleton(
        size: (widget.width ?? 100).clamp(40, 200),
        borderRadius: radius,
      );
    } else if (_localExists == true && _effectiveLocalPath != null) {
      content = Image.file(
        File(_effectiveLocalPath!),
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) => _placeholder(theme, radius),
      );
    } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      content = CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => ImageSkeleton(
          size: (widget.width ?? 100).clamp(40, 200),
          borderRadius: radius,
        ),
        errorWidget: (ctx, url, err) => _placeholder(theme, radius),
      );
    } else {
      content = _placeholder(theme, radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: content,
      ),
    );
  }

  Widget _placeholder(ThemeData theme, BorderRadius radius) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.secondary,
        size: 32,
      ),
    );
  }
}

class _QtyDialog extends StatefulWidget {
  const _QtyDialog({
    required this.product,
    required this.allowOversell,
    required this.onSaved,
  });

  final Product product;
  final bool allowOversell;
  final ValueChanged<int> onSaved;

  @override
  State<_QtyDialog> createState() => _QtyDialogState();
}

class _QtyDialogState extends State<_QtyDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final qty = int.tryParse(_ctrl.text);
    if (qty == null || qty <= 0) {
      Navigator.pop(context);
      return;
    }
    var clamped = qty;
    if (widget.product.trackStock && !widget.allowOversell) {
      clamped = qty.clamp(1, widget.product.stock);
    }
    Navigator.pop(context);
    widget.onSaved(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.product.name),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(
          labelText: l10n.quantityLabel,
          suffixText: widget.product.trackStock
              ? l10n.stockLabel(widget.product.stock)
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
