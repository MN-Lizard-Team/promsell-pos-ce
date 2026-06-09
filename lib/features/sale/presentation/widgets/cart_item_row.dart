import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_qty_stepper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/discount_dialog.dart';
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
                        context.read<SaleBloc>().add(
                          SaleItemDiscountChanged(
                            productId: item.product.id,
                            discountType: type,
                            discountValue: value,
                          ),
                        );
                      },
                      onClear: item.discountAmount > 0
                          ? () => context.read<SaleBloc>().add(
                              SaleItemDiscountCleared(item.product.id),
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
              // Zone A: Product info
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
              // Zone B: Stepper
              CartQtyStepper(
                qty: item.qty,
                onDecrement: () {
                  if (item.qty == 1) {
                    _confirmRemove(context, item, allowOversell);
                  } else {
                    context.read<SaleBloc>().add(
                      SaleItemQtyChanged(
                        productId: item.product.id,
                        qty: item.qty - 1,
                        allowOversell: allowOversell,
                      ),
                    );
                  }
                },
                onIncrement: atStockLimit
                    ? () {}
                    : () => context.read<SaleBloc>().add(
                        SaleItemQtyChanged(
                          productId: item.product.id,
                          qty: item.qty + 1,
                          allowOversell: allowOversell,
                        ),
                      ),
                onQtyTap: () => _showQtyDialog(
                  context,
                  item: item,
                  allowOversell: allowOversell,
                  atStockLimit: atStockLimit,
                ),
              ),
              const SizedBox(width: 12),
              // Zone C: Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasDiscount) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                size: 12,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '-$currency${item.discountAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontFamily: 'NotoSansThai',
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      MoneyText(
                        value: item.subtotal,
                        currency: currency,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'NotoSansThai',
                          fontWeight: FontWeight.w800,
                        ),
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQtyDialog(
    BuildContext context, {
    required CartItem item,
    required bool allowOversell,
    required bool atStockLimit,
  }) {
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
              if (qty == null || qty <= 0) return;
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

  void _confirmRemove(BuildContext context, CartItem item, bool allowOversell) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.confirmDeleteProduct(item.product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final prevItem = item;
              final bloc = context.read<SaleBloc>();
              bloc.add(
                SaleItemQtyChanged(
                  productId: item.product.id,
                  qty: 0,
                  allowOversell: allowOversell,
                ),
              );
              Navigator.pop(context);
              AppSnackBar.withAction(
                context,
                l10n.itemRemoved,
                actionLabel: l10n.undo,
                onAction: () => bloc.add(
                  SaleCartRestored(items: [...bloc.state.items, prevItem]),
                ),
              );
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
