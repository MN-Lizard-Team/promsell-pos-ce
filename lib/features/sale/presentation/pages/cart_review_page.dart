import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartReviewPage extends StatelessWidget {
  const CartReviewPage({super.key});

  void _showImageDialog(BuildContext context, CartItem item) {
    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: item.product.imagePath,
        imageUrl: item.product.imageUrl,
      ),
    );
  }

  void _showProductDetailSheet(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ProductAvatar(
                    imagePath: item.product.imagePath,
                    imageThumbnailPath: item.product.imageThumbnailPath,
                    imageUrl: item.product.imageUrl,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.product.category ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _DetailRow('Price', '฿${item.product.price.toStringAsFixed(2)}'),
              _DetailRow('Stock', '${item.product.stock}'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeQty(BuildContext context, CartItem item, int delta) {
    final newQty = (item.qty + delta).clamp(1, 9999);
    if (newQty != item.qty) {
      HapticFeedback.selectionClick();
      context.read<SaleBloc>().add(
        SaleItemQtyChanged(productId: item.product.id, qty: newQty),
      );
    }
  }

  void _removeItem(BuildContext context, CartItem item) {
    HapticFeedback.mediumImpact();
    context.read<SaleBloc>().add(SaleProductRemoved(item.product.id));
    AppSnackBar.withAction(
      context,
      '${item.product.name} removed',
      actionLabel: 'Undo',
      onAction: () {
        context.read<SaleBloc>().add(SaleProductAdded(item.product));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cartTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Add Items',
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (_, state) {
          final items = state.items;
          final itemDiscountTotal = items.fold(
            0.0,
            (s, i) => s + i.discountAmount,
          );

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return _ItemCard(
                      item: item,
                      currency: currency,
                      theme: theme,
                      onImageTap: () => _showImageDialog(context, item),
                      onRowTap: () => _showProductDetailSheet(context, item),
                      onDecrement: () => _changeQty(context, item, -1),
                      onIncrement: () => _changeQty(context, item, 1),
                      onDelete: () => _removeItem(context, item),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DottedLineRow(
                          label: context.l10n.receiptLabelSubtotal,
                          value: state.itemsSubtotal,
                          currency: currency,
                          theme: theme,
                        ),
                        if (itemDiscountTotal > 0) ...[
                          const SizedBox(height: 8),
                          _DottedLineRow(
                            label: context.l10n.receiptItemDiscounts,
                            value: -itemDiscountTotal,
                            currency: currency,
                            theme: theme,
                            valueColor: theme.colorScheme.error,
                          ),
                        ],
                        if (state.hasCartDiscount) ...[
                          const SizedBox(height: 8),
                          _DottedLineRow(
                            label: context.l10n.cartDiscount,
                            value: -state.cartDiscountAmount,
                            currency: currency,
                            theme: theme,
                            valueColor: theme.colorScheme.error,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1),
                        ),
                        Row(
                          children: [
                            Text(
                              context.l10n.totalAmount,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            MoneyText(
                              value: state.total,
                              currency: currency,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonalIcon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Payment'),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () =>
                              Navigator.of(context).popUntil((r) => r.isFirst),
                          icon: const Icon(Icons.storefront_outlined),
                          label: const Text('Back to Sale'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.item,
    required this.currency,
    required this.theme,
    required this.onImageTap,
    required this.onRowTap,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDelete,
  });

  final CartItem item;
  final String currency;
  final ThemeData theme;
  final VoidCallback onImageTap;
  final VoidCallback onRowTap;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onRowTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primaryContainer,
                      width: 2,
                    ),
                  ),
                  child: ProductAvatar(
                    imagePath: item.product.imagePath,
                    imageThumbnailPath: item.product.imageThumbnailPath,
                    imageUrl: item.product.imageUrl,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.qty} x $currency${item.product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (item.discountAmount > 0) ...[
                      const SizedBox(height: 6),
                      Chip(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                        backgroundColor: theme.colorScheme.errorContainer,
                        side: BorderSide.none,
                        avatar: Icon(
                          Icons.local_offer_outlined,
                          size: 14,
                          color: theme.colorScheme.error,
                        ),
                        label: Text(
                          '-$currency${item.discountAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _QtyButton(
                          icon: Icons.remove,
                          onPressed: onDecrement,
                          theme: theme,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showQtyDialog(context, item: item),
                          child: Text(
                            '${item.qty}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _QtyButton(
                          icon: Icons.add,
                          onPressed: onIncrement,
                          theme: theme,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: theme.colorScheme.error,
                          tooltip: 'Remove item',
                          onPressed: onDelete,
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoneyText(
                    value: item.subtotal,
                    currency: currency,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQtyDialog(BuildContext context, {required CartItem item}) {
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    final ctrl = TextEditingController(text: '${item.qty}');
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.product.name),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: InputDecoration(
            labelText: l10n.quantityLabel,
            suffixText: item.product.trackStock
                ? l10n.stockLabel(item.product.stock)
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text);
              if (qty == null || qty < 0) return;
              var clamped = qty;
              if (item.product.trackStock && !allowOversell) {
                clamped = qty.clamp(0, item.product.stock);
              }
              Navigator.pop(context);
              if (clamped != item.qty) {
                context.read<SaleBloc>().add(
                  SaleItemQtyChanged(
                    productId: item.product.id,
                    qty: clamped,
                    allowOversell: allowOversell,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatefulWidget {
  const _QtyButton({
    required this.icon,
    required this.onPressed,
    required this.theme,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final ThemeData theme;

  @override
  State<_QtyButton> createState() => _QtyButtonState();
}

class _QtyButtonState extends State<_QtyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _pressed
                ? widget.theme.colorScheme.primaryContainer
                : widget.theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.5,
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.icon,
            size: 18,
            color: widget.theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class _DottedLineRow extends StatelessWidget {
  const _DottedLineRow({
    required this.label,
    required this.value,
    required this.currency,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final double value;
  final String currency;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textStyle = theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outlineVariant,
                letterSpacing: 1.5,
              );
              final textSpan = TextSpan(text: '.', style: textStyle);
              final painter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.ltr,
              )..layout();
              final dotWidth = painter.width;
              final count = (constraints.maxWidth / dotWidth).floor();
              return Text(
                '.' * count.clamp(0, 100),
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.clip,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        MoneyText(
          value: value,
          currency: currency,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          color: valueColor ?? theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
