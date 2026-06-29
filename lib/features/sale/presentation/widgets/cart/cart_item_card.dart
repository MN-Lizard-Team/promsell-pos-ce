import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_qty_button.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.currency,
    required this.onImageTap,
    required this.onRowTap,
    required this.onDecrement,
    required this.onIncrement,
    required this.onDelete,
  });

  final CartItem item;
  final String currency;
  final VoidCallback onImageTap;
  final VoidCallback onRowTap;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onRowTap,
        borderRadius: BorderRadius.circular(14),
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
                        color: theme.colorScheme.secondary,
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
                        CartQtyButton(
                          icon: Icons.remove,
                          onPressed: onDecrement,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showQtyDialog(context),
                          child: Text(
                            '${item.qty}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CartQtyButton(icon: Icons.add, onPressed: onIncrement),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: theme.colorScheme.error,
                          tooltip: context.l10n.removeItem,
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
              Expanded(
                flex: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MoneyText(
                      value: item.subtotal,
                      currency: currency,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: 'NotoSansThai',
                        fontWeight: FontWeight.w700,
                      ),
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQtyDialog(BuildContext context) {
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    showDialog(
      context: context,
      builder: (_) => _CartItemQtyDialog(
        item: item,
        allowOversell: allowOversell,
        onSaved: (qty) {
          if (qty != item.qty) {
            context.read<CartBloc>().add(
              CartItemQtyChanged(
                productId: item.product.id,
                qty: qty,
                allowOversell: allowOversell,
              ),
            );
          }
        },
      ),
    );
  }
}

class _CartItemQtyDialog extends StatefulWidget {
  const _CartItemQtyDialog({
    required this.item,
    required this.allowOversell,
    required this.onSaved,
  });

  final CartItem item;
  final bool allowOversell;
  final ValueChanged<int> onSaved;

  @override
  State<_CartItemQtyDialog> createState() => _CartItemQtyDialogState();
}

class _CartItemQtyDialogState extends State<_CartItemQtyDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.item.qty}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final qty = int.tryParse(_ctrl.text);
    if (qty == null || qty <= 0) return;
    var clamped = qty;
    if (widget.item.product.trackStock && !widget.allowOversell) {
      clamped = qty.clamp(0, widget.item.product.stock);
    }
    Navigator.pop(context);
    if (clamped != widget.item.qty) {
      widget.onSaved(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.item.product.name),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(
          labelText: l10n.quantityLabel,
          suffixText: widget.item.product.trackStock
              ? l10n.stockLabel(widget.item.product.stock)
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
