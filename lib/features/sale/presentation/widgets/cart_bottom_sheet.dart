import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_avatar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/checkout_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_qty_stepper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartBottomSheet {
  static void show(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.read<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final saleBloc = context.read<SaleBloc>();

    final mediaQuery = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height - mediaQuery.padding.top,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final draggableController = DraggableScrollableController();
        return BlocProvider.value(
          value: saleBloc,
          child: DraggableScrollableSheet(
            controller: draggableController,
            expand: false,
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (sheetCtx, scrollController) {
              final bottomInset = MediaQuery.paddingOf(sheetCtx).bottom;
              return Column(
                children: [
                  // Header (non-scrolling)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
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
                        const SizedBox(height: 12),
                        Text(
                          ctx.l10n.cartTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  // Scrollable items
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<SaleBloc, SaleState>(
                        builder: (_, state) {
                          if (state.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ctx.l10n.tapProductToAdd,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: state.items.length,
                            itemBuilder: (listCtx, index) {
                              final item = state.items[index];
                              final bloc = listCtx.read<SaleBloc>();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _CartItemTile(
                                  item: item,
                                  currency: currency,
                                  settings: settings,
                                  onIncrement: () =>
                                      _changeQty(listCtx, bloc, item, 1),
                                  onDecrement: () =>
                                      _changeQty(listCtx, bloc, item, -1),
                                  onDelete: () =>
                                      _removeItem(listCtx, bloc, item),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  // Pinned summary at bottom
                  BlocBuilder<SaleBloc, SaleState>(
                    builder: (_, state) {
                      if (state.isEmpty) {
                        return SizedBox(height: bottomInset + 16);
                      }
                      final itemDiscountTotal = state.items.fold(
                        0.0,
                        (s, i) => s + i.discountAmount,
                      );
                      return Container(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          16 + bottomInset,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border(
                            top: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SummaryRow(
                              label: ctx.l10n.receiptLabelSubtotal,
                              value: state.itemsSubtotal,
                              currency: currency,
                              theme: theme,
                            ),
                            if (itemDiscountTotal > 0) ...[
                              const SizedBox(height: 2),
                              _SummaryRow(
                                label: ctx.l10n.receiptItemDiscounts,
                                value: -itemDiscountTotal,
                                currency: currency,
                                theme: theme,
                                valueColor: theme.colorScheme.error,
                              ),
                            ],
                            if (state.hasCartDiscount) ...[
                              const SizedBox(height: 2),
                              _SummaryRow(
                                label: ctx.l10n.cartDiscount,
                                value: -state.cartDiscountAmount,
                                currency: currency,
                                theme: theme,
                                valueColor: theme.colorScheme.error,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Divider(height: 1),
                            ),
                            Row(
                              children: [
                                Text(
                                  ctx.l10n.totalAmount,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Spacer(),
                                MoneyText(
                                  value: state.total,
                                  currency: currency,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                            if (settings.enableCartDiscount) ...[
                              const SizedBox(height: 4),
                              TextButton.icon(
                                onPressed: () =>
                                    DiscountDialog.showCartDiscount(
                                      context,
                                      title: ctx.l10n.cartDiscount,
                                      currency: currency,
                                      initialType:
                                          state.cartDiscountType ??
                                          settings.defaultDiscountType,
                                      initialValue: state.cartDiscountValue,
                                      onApply: (type, value) {
                                        context.read<SaleBloc>().add(
                                          SaleCartDiscountChanged(
                                            discountType: type,
                                            discountValue: value,
                                          ),
                                        );
                                      },
                                      onClear: state.hasCartDiscount
                                          ? () => context.read<SaleBloc>().add(
                                              const SaleCartDiscountCleared(),
                                            )
                                          : null,
                                      maxPercent: settings.maxDiscountPercent,
                                      maxAmount: settings.maxDiscountAmount,
                                      presetValues:
                                          settings.activeDiscountPreset.values,
                                      presetType:
                                          settings.activeDiscountPreset.type,
                                    ),
                                icon: Icon(
                                  state.hasCartDiscount
                                      ? Icons.local_offer
                                      : Icons.local_offer_outlined,
                                  size: 18,
                                ),
                                label: Text(
                                  state.hasCartDiscount
                                      ? ctx.l10n.cartDiscount
                                      : ctx.l10n.applyCartDiscount,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            FilledButton.icon(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                Navigator.of(ctx).pop();
                                final saleBloc = context.read<SaleBloc>();
                                final settingsCubit = context
                                    .read<SettingsCubit>();
                                final s = settingsCubit.state.settings;
                                final today = DateTime.now()
                                    .toIso8601String()
                                    .split('T')
                                    .first;
                                if (s.dailyCloseLock &&
                                    s.lastClosedDate == today) {
                                  AppSnackBar.error(
                                    context,
                                    context.l10n.dayClosedMessage,
                                  );
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider.value(value: saleBloc),
                                        BlocProvider.value(
                                          value: settingsCubit,
                                        ),
                                      ],
                                      child: const CheckoutPage(),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 18,
                              ),
                              label: Text(ctx.l10n.checkout(state.itemCount)),
                              style: theme.filledButtonTheme.style?.copyWith(
                                minimumSize: const WidgetStatePropertyAll(
                                  Size(double.infinity, 44),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static void _changeQty(
    BuildContext context,
    SaleBloc bloc,
    CartItem item,
    int delta,
  ) {
    if (delta < 0 && item.qty == 1) {
      _removeItem(context, bloc, item);
      return;
    }
    final newQty = (item.qty + delta).clamp(1, 9999);
    if (newQty != item.qty) {
      HapticFeedback.selectionClick();
      bloc.add(SaleItemQtyChanged(productId: item.product.id, qty: newQty));
    }
  }

  static void _removeItem(BuildContext context, SaleBloc bloc, CartItem item) {
    HapticFeedback.mediumImpact();
    bloc.add(SaleProductRemoved(item.product.id));
    AppSnackBar.withAction(
      context,
      context.l10n.itemRemoved,
      actionLabel: context.l10n.undo,
      onAction: () {
        bloc.add(SaleCartItemRestored(item));
      },
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.currency,
    required this.settings,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final CartItem item;
  final String currency;
  final AppSettings settings;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
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
                  onQtyTap: () {},
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.currency,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final double value;
  final String currency;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        MoneyText(
          value: value,
          currency: currency,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          color: valueColor ?? theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
