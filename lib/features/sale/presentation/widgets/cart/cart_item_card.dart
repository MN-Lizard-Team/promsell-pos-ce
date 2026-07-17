import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_qty_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_qty_button.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Receipt-style cart line: name · discount badge · qty · line total.
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
    this.onMoreActions,
  });

  final CartItem item;
  final String currency;
  final VoidCallback onImageTap;
  final VoidCallback onRowTap;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;
  final Widget? onMoreActions;

  void _openQtyDialog(BuildContext context) {
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    CartQtyDialog.show(
      context,
      bloc: context.read<CartBloc>(),
      item: item,
      allowOversell: allowOversell,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final optionsLabel = item.selectedOptions
        .map((o) => o.optionName)
        .join(' · ');
    final hasDisc = item.discountAmount.value > 0;
    final unitLabel =
        '${item.qty} × ${CurrencyFormatter.formatGroupedWithSymbol(item.product.price.value, currency)}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRowTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onImageTap,
                child: ProductAvatar(
                  imagePath: item.product.imagePath,
                  imageThumbnailPath: item.product.imageThumbnailPath,
                  imageUrl: item.product.imageUrl,
                  size: 40,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MoneyText(
                          value: item.subtotal.value,
                          currency: currency,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFamily: 'NotoSansThai',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          color: theme.colorScheme.onSurface,
                        ),
                      ],
                    ),
                    if (optionsLabel.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        optionsLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (item.note != null && item.note!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.noteLabel(item.note!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (hasDisc) ...[
                          _DiscountBadge(
                            label:
                                '-${CurrencyFormatter.formatGroupedWithSymbol(item.discountAmount.value, currency)}',
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            unitLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        CartQtyButton(
                          icon: Icons.remove,
                          tooltip: context.l10n.quantityLabel,
                          onPressed: onDecrement,
                        ),
                        InkWell(
                          onTap: () => _openQtyDialog(context),
                          onLongPress: () => _openQtyDialog(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.qty}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        CartQtyButton(
                          icon: Icons.add,
                          tooltip: context.l10n.quantityLabel,
                          onPressed: onIncrement,
                        ),
                        ?onMoreActions,
                      ],
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
}

class _DiscountBadge extends StatelessWidget {
  const _DiscountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
