import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_qty_stepper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.currency,
    required this.settings,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQtyTap,
    required this.onDelete,
    this.onDuplicate,
  });

  final CartItem item;
  final String currency;
  final Settings settings;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onQtyTap;
  final VoidCallback onDelete;
  final VoidCallback? onDuplicate;

  void _showDiscountDialog(BuildContext context) {
    DiscountDialog.showItemDiscount(
      context,
      title: item.product.name,
      currency: currency,
      initialType: item.discountType ?? settings.defaultDiscountType,
      initialValue: item.discountValue,
      maxPercent: settings.maxDiscountPercent,
      maxAmount: settings.maxDiscountAmount,
      presetValues: settings.activeDiscountPreset.values,
      presetType: settings.activeDiscountPreset.type,
      onApply: (type, value) {
        context.read<CartBloc>().add(
          CartItemDiscountChanged(
            productId: item.product.id,
            discountType: type,
            discountValue: value,
          ),
        );
      },
      onClear: item.discountAmount > 0
          ? () => context.read<CartBloc>().add(
              CartItemDiscountCleared(item.product.id),
            )
          : null,
    );
  }

  void _showNoteDialog(BuildContext context) {
    final controller = TextEditingController(text: item.note ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.itemNoteLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 2,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: context.l10n.itemNoteHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          if (item.note != null && item.note!.isNotEmpty)
            TextButton(
              onPressed: () {
                context.read<CartBloc>().add(
                  CartItemNoteChanged(productId: item.product.id, note: null),
                );
                Navigator.pop(ctx);
              },
              child: Text(context.l10n.clear),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final note = controller.text.trim();
              context.read<CartBloc>().add(
                CartItemNoteChanged(
                  productId: item.product.id,
                  note: note.isEmpty ? null : note,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = item.discountAmount > 0;

    final skuOrBarcode = item.product.sku ?? item.product.barcode;
    final stockText = item.product.trackStock
        ? context.l10n.stockRemaining(item.product.stock)
        : '\u221e';
    final stockColor = !item.product.trackStock
        ? theme.colorScheme.secondary
        : item.product.stock == 0
        ? theme.colorScheme.error
        : item.product.stock <= 5
        ? theme.colorScheme.tertiary
        : theme.colorScheme.secondary;

    return GestureDetector(
      onLongPress: onDuplicate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: settings.enableItemDiscount
                  ? () => _showDiscountDialog(context)
                  : null,
              child: ProductAvatar(
                imagePath: item.product.imagePath,
                imageThumbnailPath: item.product.imageThumbnailPath,
                imageUrl: item.product.imageUrl,
                size: 36,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: settings.enableItemDiscount
                    ? () => _showDiscountDialog(context)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.product.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (skuOrBarcode != null && skuOrBarcode.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        skuOrBarcode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        MoneyText(
                          value: item.product.price,
                          currency: currency,
                          style: theme.textTheme.bodySmall,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: MoneyText(
                                value: -item.discountAmount,
                                currency: currency,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stockText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: stockColor,
                        fontSize: 11,
                      ),
                    ),
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () => _showNoteDialog(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note_outlined,
                              size: 12,
                              color: theme.colorScheme.tertiary,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                item.note!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.tertiary,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CartQtyStepper(
                  qty: item.qty,
                  onDecrement: onDecrement,
                  onIncrement: onIncrement,
                  onQtyTap: onQtyTap,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasDiscount)
                      Text(
                        '$currency${(item.product.price * item.qty).toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    MoneyText(
                      value: item.subtotal,
                      currency: currency,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            IconButton.filledTonal(
              icon: const Icon(Icons.delete_outline, size: 16),
              color: theme.colorScheme.error,
              onPressed: () {
                HapticFeedback.mediumImpact();
                onDelete();
              },
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
