import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartItemRow extends StatelessWidget {
  const CartItemRow({super.key, required this.item, required this.currency});

  final CartItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    final atStockLimit =
        item.product.trackStock &&
        !allowOversell &&
        item.qty >= item.product.stock;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      MoneyText(
                        value: item.product.price,
                        currency: currency,
                        style: theme.textTheme.bodySmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      if (item.discountAmount > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          context.l10n.discountLabel(
                            item.discountAmount.toStringAsFixed(2),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                item.discountAmount > 0
                    ? Icons.local_offer
                    : Icons.local_offer_outlined,
                size: 18,
                color: item.discountAmount > 0
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              tooltip: context.l10n.discountDialogTitle,
              onPressed: () => DiscountDialog.showItemDiscount(
                context,
                title: item.product.name,
                currency: currency,
                initialType: item.discountType ?? 'PERCENT',
                initialValue: item.discountValue,
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
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.qty == 1)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    tooltip: context.l10n.removeItem,
                    onPressed: () {
                      final prevItem = item;
                      final bloc = context.read<SaleBloc>();
                      final l10n = context.l10n;
                      bloc.add(
                        SaleItemQtyChanged(
                          productId: item.product.id,
                          qty: 0,
                          allowOversell: allowOversell,
                        ),
                      );
                      AppSnackBar.withAction(
                        context,
                        l10n.itemRemoved,
                        actionLabel: l10n.undo,
                        onAction: () => bloc.add(
                          SaleCartRestored(
                            items: [...bloc.state.items, prevItem],
                          ),
                        ),
                      );
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => context.read<SaleBloc>().add(
                      SaleItemQtyChanged(
                        productId: item.product.id,
                        qty: item.qty - 1,
                        allowOversell: allowOversell,
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 32),
                  child: Text(
                    '${item.qty}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: atStockLimit ? context.l10n.stockLimitReached : null,
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
                if (atStockLimit)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 82),
              child: MoneyText(
                value: item.subtotal,
                currency: currency,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
