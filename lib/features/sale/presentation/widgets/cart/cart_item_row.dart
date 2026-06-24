import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_row/cart_item_dialogs.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_row/cart_item_price.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_qty_stepper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartItemRow extends StatelessWidget {
  const CartItemRow({
    super.key,
    required this.item,
    required this.currency,
    this.compact = false,
    this.ultraCompact = false,
    this.isSelecting = false,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.dragHandleIndex,
  });

  final CartItem item;
  final String currency;
  final bool compact;
  final bool ultraCompact;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final int? dragHandleIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.read<SettingsCubit>().state.settings;
    final allowOversell = settings.allowOversell;
    final enableItemDiscount = settings.enableItemDiscount;
    final atStockLimit =
        item.product.trackStock &&
        !allowOversell &&
        item.qty >= item.product.stock;
    final hasDiscount = item.discountAmount > 0;

    final pad = ultraCompact ? 6.0 : (compact ? 8.0 : 12.0);
    final avatarSize = ultraCompact ? 28.0 : (compact ? 32.0 : 40.0);
    final nameStyle = ultraCompact
        ? theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'NotoSansThai',
            fontWeight: FontWeight.w700,
          )
        : theme.textTheme.bodyMedium?.copyWith(
            fontFamily: 'NotoSansThai',
            fontWeight: FontWeight.w700,
          );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'NotoSansThai',
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isSelecting
            ? onTap
            : (enableItemDiscount
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
                  : null),
        onLongPress: isSelecting ? null : onLongPress,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSelecting) ...[
                Checkbox(value: isSelected, onChanged: (_) => onTap?.call()),
                const SizedBox(width: 8),
              ],
              ProductAvatar(
                imagePath: item.product.imagePath,
                imageThumbnailPath: item.product.imageThumbnailPath,
                imageUrl: item.product.imageUrl,
                size: avatarSize,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: nameStyle,
                    ),
                    if (!ultraCompact) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$currency${item.product.price.toStringAsFixed(2)} x ${item.qty}',
                        style: subtitleStyle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CartQtyStepper(
                qty: item.qty,
                onDecrement: () {
                  if (item.qty == 1) {
                    CartItemRemoveDialog.show(context, item, allowOversell);
                  } else {
                    context.read<CartBloc>().add(
                      CartItemQtyChanged(
                        productId: item.product.id,
                        qty: item.qty - 1,
                        allowOversell: allowOversell,
                      ),
                    );
                  }
                },
                onIncrement: atStockLimit
                    ? () {}
                    : () => context.read<CartBloc>().add(
                        CartItemQtyChanged(
                          productId: item.product.id,
                          qty: item.qty + 1,
                          allowOversell: allowOversell,
                        ),
                      ),
                onQtyTap: () => CartItemQtyDialog.show(
                  context,
                  item: item,
                  allowOversell: allowOversell,
                  atStockLimit: atStockLimit,
                ),
              ),
              const SizedBox(width: 12),
              CartItemPriceColumn(
                currency: currency,
                item: item,
                hasDiscount: hasDiscount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
