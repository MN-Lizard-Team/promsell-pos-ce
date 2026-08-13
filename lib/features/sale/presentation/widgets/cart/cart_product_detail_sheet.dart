import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_detail_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class CartProductDetailSheet {
  CartProductDetailSheet._();

  static void show(
    BuildContext context,
    CartItem item, {
    VoidCallback? onEditNote,
    VoidCallback? onEditDiscount,
  }) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currency = context.read<SettingsCubit>().state.settings.currency;
    final pos = context.posTheme;

    PosBottomSheet.show<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProductAvatar(
                    imagePath: item.product.imagePath,
                    imageThumbnailPath: item.product.imageThumbnailPath,
                    imageUrl: item.product.imageUrl,
                    size: 64,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
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
                  MoneyText(
                    value: item.subtotal.value,
                    currency: currency,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontFamily: 'NotoSansThai',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: pos.billStubBorder),
              const SizedBox(height: 12),
              if (item.selectedOptions.isNotEmpty) ...[
                Text(
                  l10n.selectOptions,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                for (final opt in item.selectedOptions)
                  CartDetailRow(
                    '${opt.groupName}: ${opt.optionName}',
                    opt.priceDelta.isPositive
                        ? '+$currency${opt.priceDelta.value.toStringAsFixed(2)}'
                        : '-',
                  ),
                const SizedBox(height: 8),
              ],
              CartDetailRow(
                l10n.receiptLabelSubtotal,
                '$currency${item.product.price.value.toStringAsFixed(2)} × ${item.qty}',
              ),
              CartDetailRow(l10n.quantityLabel, '${item.qty}'),
              MoneyDetailRow(
                label: l10n.totalAmount,
                value: item.subtotal.value,
                currency: currency,
                theme: theme,
              ),
              if (item.discountAmount.isPositive)
                CartDetailRow(
                  l10n.discountSectionLabel,
                  '-$currency${item.discountAmount.value.toStringAsFixed(2)}',
                ),
              if (item.note != null && item.note!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.itemNoteLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: pos.billStubBorder),
                  ),
                  child: Text(item.note!),
                ),
              ],
              const SizedBox(height: 10),
              _StockStatusRow(item: item, theme: theme, l10n: l10n),
              const SizedBox(height: 16),
              if (onEditNote != null || onEditDiscount != null) ...[
                Row(
                  children: [
                    if (onEditNote != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            onEditNote();
                          },
                          icon: const Icon(Icons.note_alt_outlined, size: 18),
                          label: Text(l10n.itemNoteLabel),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            side: BorderSide(color: pos.billStubBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    if (onEditNote != null && onEditDiscount != null)
                      const SizedBox(width: 8),
                    if (onEditDiscount != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            onEditDiscount();
                          },
                          icon: const Icon(
                            Icons.local_offer_outlined,
                            size: 18,
                          ),
                          label: Text(l10n.discountSectionLabel),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            side: BorderSide(color: pos.billStubBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.close,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
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
  final AppLocalizations l10n;

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
    } else if (stock <=
        context.read<SettingsCubit>().state.settings.lowStockThreshold) {
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label (${l10n.stockRemaining(stock)})',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
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
