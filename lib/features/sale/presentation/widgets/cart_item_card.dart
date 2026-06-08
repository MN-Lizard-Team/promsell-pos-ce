import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_qty_button.dart';
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

  void _showQtyDialog(BuildContext context) {
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
