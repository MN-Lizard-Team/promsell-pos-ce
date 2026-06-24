import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  });

  final CartItem item;
  final String currency;
  final Settings settings;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onQtyTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDiscount = item.discountAmount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: settings.enableItemDiscount
                ? () => DiscountDialog.showItemDiscount(
                    context,
                    title: item.product.name,
                    currency: currency,
                    initialType:
                        item.discountType ?? settings.defaultDiscountType,
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
                  )
                : null,
            child: ProductAvatar(
              imagePath: item.product.imagePath,
              imageThumbnailPath: item.product.imageThumbnailPath,
              imageUrl: item.product.imageUrl,
              size: 40,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: settings.enableItemDiscount
                      ? () => DiscountDialog.showItemDiscount(
                          context,
                          title: item.product.name,
                          currency: currency,
                          initialType:
                              item.discountType ?? settings.defaultDiscountType,
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
                        )
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
                                child: Text(
                                  '-$currency${item.discountAmount.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                CartQtyStepper(
                  qty: item.qty,
                  onDecrement: onDecrement,
                  onIncrement: onIncrement,
                  onQtyTap: onQtyTap,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton.filledTonal(
                icon: const Icon(Icons.delete_outline, size: 18),
                color: theme.colorScheme.error,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onDelete();
                },
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  minimumSize: const Size(36, 36),
                ),
              ),
              const SizedBox(height: 4),
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
    );
  }
}
