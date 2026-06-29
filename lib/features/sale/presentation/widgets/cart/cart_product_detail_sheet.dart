import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_detail_row.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CartProductDetailSheet {
  CartProductDetailSheet._();

  static void show(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currency = context.read<SettingsCubit>().state.settings.currency;
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: false,
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
                          item.product.category ?? l10n.noCategory,
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
              CartDetailRow(
                l10n.receiptLabelSubtotal,
                '$currency${item.product.price.toStringAsFixed(2)} x ${item.qty}',
              ),
              CartDetailRow(l10n.quantityLabel, '${item.qty}'),
              MoneyDetailRow(
                label: l10n.totalAmount,
                value: item.subtotal,
                currency: currency,
                theme: theme,
              ),
              if (item.discountAmount > 0)
                CartDetailRow(
                  l10n.discountSectionLabel,
                  '-$currency${item.discountAmount.toStringAsFixed(2)}',
                ),
              if (item.note != null && item.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.itemNoteLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(item.note!),
                ),
              ],
              const SizedBox(height: 8),
              _StockStatusRow(item: item, theme: theme, l10n: l10n),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockStatusRow extends StatelessWidget {
  const _StockStatusRow({
    required this.item,
    required this.theme,
    required this.l10n,
  });

  final CartItem item;
  final ThemeData theme;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    if (!product.trackStock) return const SizedBox.shrink();

    final stock = product.stock;
    final Color color;
    final String label;
    final IconData icon;

    if (stock == 0) {
      color = theme.colorScheme.error;
      label = l10n.outOfStock;
      icon = Icons.error_outline;
    } else if (stock <= 5) {
      color = theme.colorScheme.tertiary;
      label = l10n.lowStock;
      icon = Icons.warning_amber;
    } else {
      color = theme.colorScheme.primary;
      label = l10n.inStock;
      icon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label (${l10n.stockRemaining(stock)})',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MoneyDetailRow extends StatelessWidget {
  const MoneyDetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    required this.theme,
  });

  final String label;
  final double value;
  final String currency;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const Spacer(),
          MoneyText(
            value: value,
            currency: currency,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}
