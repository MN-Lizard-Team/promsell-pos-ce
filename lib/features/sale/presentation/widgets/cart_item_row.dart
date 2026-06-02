import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
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

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
          padding: ultraCompact
              ? const EdgeInsets.fromLTRB(8, 4, 6, 4)
              : compact
              ? const EdgeInsets.fromLTRB(10, 6, 8, 6)
              : const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            children: [
              if (isSelecting) ...[
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap?.call(),
                  shape: const CircleBorder(),
                ),
                const SizedBox(width: 4),
              ],
              ProductAvatar(
                imagePath: item.product.imagePath,
                imageThumbnailPath: item.product.imageThumbnailPath,
                imageUrl: item.product.imageUrl,
                size: ultraCompact ? 28 : (compact ? 32 : 44),
              ),
              SizedBox(width: ultraCompact ? 6 : (compact ? 8 : 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (ultraCompact
                                  ? theme.textTheme.labelSmall
                                  : compact
                                  ? theme.textTheme.bodySmall
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (!ultraCompact) ...[
                      SizedBox(height: compact ? 0 : 2),
                      Row(
                        children: [
                          MoneyText(
                            value: item.product.price,
                            currency: currency,
                            style: compact
                                ? theme.textTheme.labelSmall
                                : theme.textTheme.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          if (item.discountAmount > 0) ...[
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
                    ] else if (item.discountAmount > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-$currency${item.discountAmount.toStringAsFixed(2)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QtyButton(
                    icon: Icons.remove,
                    onPressed: () {
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
                  ),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: ultraCompact ? 24 : 28,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.qty}',
                      style:
                          (ultraCompact
                                  ? theme.textTheme.bodySmall
                                  : compact
                                  ? theme.textTheme.bodyMedium
                                  : theme.textTheme.titleMedium)
                              ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Tooltip(
                    message: atStockLimit ? context.l10n.atStockLimit : '',
                    child: _QtyButton(
                      icon: Icons.add,
                      onPressed: atStockLimit
                          ? null
                          : () => context.read<SaleBloc>().add(
                              SaleItemQtyChanged(
                                productId: item.product.id,
                                qty: item.qty + 1,
                                allowOversell: allowOversell,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: ultraCompact ? 56 : (compact ? 68 : 84),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: MoneyText(
                    value: item.subtotal,
                    currency: currency,
                    textAlign: TextAlign.right,
                    style:
                        (ultraCompact
                                ? theme.textTheme.labelSmall
                                : compact
                                ? theme.textTheme.bodySmall
                                : theme.textTheme.bodyMedium)
                            ?.copyWith(fontWeight: FontWeight.w700),
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (dragHandleIndex != null) ...[
                const SizedBox(width: 6),
                Tooltip(
                  message: context.l10n.reorderItem,
                  child: ReorderableDragStartListener(
                    index: dragHandleIndex!,
                    child: Icon(
                      Icons.drag_indicator,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        focusColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onPressed == null
                ? null
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: onPressed == null
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
