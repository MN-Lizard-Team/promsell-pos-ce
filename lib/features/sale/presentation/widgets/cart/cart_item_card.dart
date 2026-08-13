import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_qty_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_qty_button.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Clean cart line on bill paper.
///
/// Tap = detail · long-press = more · swipe left = delete.
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
    this.onLongPress,
    this.onMoreActions,
    this.enabled = true,
  });

  final CartItem item;
  final String currency;
  final VoidCallback onImageTap;
  final VoidCallback onRowTap;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;
  final Widget? onMoreActions;
  final bool enabled;

  void _openQtyDialog(BuildContext context) {
    if (!enabled) return;
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
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    final l10n = context.l10n;
    final product = item.product;

    final optionsLabel = item.selectedOptions
        .map((o) => o.optionName)
        .join(' · ');
    final hasDisc = item.discountAmount.value > 0;
    final hasNote = item.note != null && item.note!.trim().isNotEmpty;
    final unitPrice = CurrencyFormatter.formatGroupedWithSymbol(
      product.price.value,
      currency,
    );
    final sku = product.sku?.trim() ?? '';

    final meta = <String>[
      if (sku.isNotEmpty) '${l10n.skuLabel}: $sku',
      if (optionsLabel.isNotEmpty) optionsLabel,
      if (hasNote) item.note!.trim(),
      '@ $unitPrice',
      if (hasDisc)
        '-${CurrencyFormatter.formatGroupedWithSymbol(item.discountAmount.value, currency)}',
    ].join(' · ');

    final unavailable = !item.isAvailable;
    final row = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onRowTap : null,
        onLongPress: enabled && onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                onLongPress!();
              }
            : null,
        child: Opacity(
          opacity: enabled ? (unavailable ? 0.6 : 1) : 0.55,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onImageTap,
                  child: ProductAvatar(
                    imagePath: product.imagePath,
                    imageThumbnailPath: product.imageThumbnailPath,
                    imageUrl: product.imageUrl,
                    size: 52,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (unavailable)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: scheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.productDeleted,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                height: 1.25,
                                color: scheme.onSurface,
                                fontFamily: 'NotoSansThai',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MoneyText(
                            value: item.subtotal.value,
                            currency: currency,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              height: 1.2,
                              color: scheme.primary,
                              fontFamily: 'NotoSansThai',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _QtyStepper(
                            qty: item.qty,
                            enabled: enabled,
                            onDecrement: onDecrement,
                            onIncrement: onIncrement,
                            onQtyTap: () => _openQtyDialog(context),
                            pos: pos,
                            theme: theme,
                            qtyTooltip: l10n.quantityLabel,
                          ),
                          if (enabled && onMoreActions != null) onMoreActions!,
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!enabled) return row;

    return Dismissible(
      key: ValueKey('sale_cart_dismiss_${item.lineId}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: scheme.error,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l10n.delete,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onError,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline, color: scheme.onError, size: 22),
          ],
        ),
      ),
      child: row,
    );
  }
}

/// Compact [−][n][+] — one qty source, fits narrow dock.
class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.enabled,
    required this.onDecrement,
    required this.onIncrement,
    required this.onQtyTap,
    required this.pos,
    required this.theme,
    required this.qtyTooltip,
  });

  final int qty;
  final bool enabled;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onQtyTap;
  final PosThemeExtension pos;
  final ThemeData theme;
  final String qtyTooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: pos.billStubBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CartQtyButton(
            icon: Icons.remove,
            tooltip: qtyTooltip,
            onPressed: enabled ? onDecrement : null,
            bare: true,
          ),
          InkWell(
            onTap: enabled ? onQtyTap : null,
            onLongPress: enabled ? onQtyTap : null,
            child: SizedBox(
              width: 36,
              height: 34,
              child: Center(
                child: Text(
                  '$qty',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    fontFamily: 'NotoSansThai',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          CartQtyButton(
            icon: Icons.add,
            tooltip: qtyTooltip,
            onPressed: enabled ? onIncrement : null,
            bare: true,
          ),
        ],
      ),
    );
  }
}
