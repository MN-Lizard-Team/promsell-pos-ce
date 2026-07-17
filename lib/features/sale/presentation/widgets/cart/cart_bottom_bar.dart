import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_sheet.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartBottomBar extends StatefulWidget {
  const CartBottomBar({super.key});

  static double contentInset(BuildContext context) =>
      96 + MediaQuery.viewPaddingOf(context).bottom;

  @override
  State<CartBottomBar> createState() => _CartBottomBarState();
}

class _CartBottomBarState extends State<CartBottomBar>
    with SingleTickerProviderStateMixin {
  bool _bounce = false;

  void _triggerBounce() {
    if (!mounted) return;
    setState(() => _bounce = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _bounce = false);
    });
  }

  void _openReview(BuildContext context) {
    openCartReviewPage(context);
  }

  void _pay(BuildContext context) {
    navigateToCheckout(context);
  }

  /// Long-press Pay: exact cash without payment sheet (retail speed path).
  void _expressCashPay(
    BuildContext context,
    CartState cart,
    Settings settings,
  ) {
    if (cart.isEmpty) return;
    if (SalesDayLock.isCreateBlocked(
      dailyCloseLock: settings.dailyCloseLock,
      lastClosedDate: settings.lastClosedDate,
    )) {
      AppSnackBar.error(context, context.l10n.dayClosedMessage);
      return;
    }
    // Restaurant needs order/table UI — fall back to full checkout.
    if (settings.isRestaurantMode) {
      navigateToCheckout(context);
      return;
    }
    final payable = cart.payableTotals(settings);
    final due = payable.payableTotal;
    context.read<CheckoutBloc>().add(
      CheckoutConfirmed(
        paymentMethod: 'cash',
        vatMode: settings.vatMode,
        vatRate: settings.vatRate,
        cartDiscountType: cart.cartDiscountType,
        cartDiscountValue: cart.cartDiscountValue,
        cartDiscountAmount: cart.cartDiscountAmount,
        amountReceived: due,
        changeAmount: Money.zero,
        note: cart.note.isEmpty ? null : cart.note,
        orderType: cart.orderType,
        orderChannel: cart.orderChannel,
        externalOrderRef: cart.externalOrderRef,
        tableId: cart.tableId,
        serviceChargeRate: payable.serviceChargeRate,
        serviceChargeAmount: payable.serviceChargeAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final dayClosed = SalesDayLock.isCreateBlocked(
      dailyCloseLock: settings.dailyCloseLock,
      lastClosedDate: settings.lastClosedDate,
    );

    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) => prev.itemCount != curr.itemCount,
      listener: (context, state) => _triggerBounce(),
      child: RepaintBoundary(
        child: BlocBuilder<CartBloc, CartState>(
          // Rebuild when any input to payableTotals may change.
          buildWhen: (prev, curr) =>
              prev.itemCount != curr.itemCount ||
              prev.total != curr.total ||
              prev.grandTotal != curr.grandTotal ||
              prev.itemsSubtotal != curr.itemsSubtotal ||
              prev.cartDiscountAmount != curr.cartDiscountAmount ||
              prev.serviceChargeAmount != curr.serviceChargeAmount ||
              prev.promotionDiscountAmount != curr.promotionDiscountAmount ||
              prev.serviceChargeRate != curr.serviceChargeRate ||
              prev.cartDiscountType != curr.cartDiscountType ||
              prev.cartDiscountValue != curr.cartDiscountValue,
          builder: (ctx, state) {
            final count = state.itemCount;
            final isEmpty = count == 0;
            final payable = state.payableTotals(settings).payableTotal;
            final pos = ctx.posTheme;
            final amountLabel =
                '$currency${payable.value.toStringAsFixed(payable.value == payable.value.roundToDouble() ? 0 : 2)}';

            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Material(
                color: theme.colorScheme.surface,
                elevation: 8,
                shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.18),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(pos.stickyBarRadius),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    12 + MediaQuery.viewPaddingOf(context).bottom,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      );
                    },
                    child: isEmpty
                        ? Row(
                            key: const ValueKey('empty'),
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 22,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  context.l10n.tapProductToAdd,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Wireframe: circular count badge on the right.
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '0',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: ValueKey('bill-$count'),
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    _openReview(ctx);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  // Wireframe: cart icon | Cart + total | count badge
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart,
                                        size: 24,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              context.l10n.cartBottomLabel,
                                              style: theme.textTheme.labelMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            MoneyText(
                                              value: payable.value,
                                              currency: currency,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontFamily: 'NotoSansThai',
                                                    fontWeight: FontWeight.w800,
                                                    height: 1.1,
                                                  ),
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedScale(
                                        scale: _bounce ? 1.2 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOutBack,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: pos.qtyBadgeBackground,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '$count',
                                            key: ValueKey(count),
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  color: pos.qtyBadgeForeground,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              FilledButton.icon(
                                key: const ValueKey('sale-pay-cta'),
                                onPressed: dayClosed
                                    ? () {
                                        HapticFeedback.heavyImpact();
                                        // Helper shows day-closed snack.
                                        _pay(ctx);
                                      }
                                    : () {
                                        HapticFeedback.selectionClick();
                                        _pay(ctx);
                                      },
                                onLongPress: dayClosed
                                    ? null
                                    : () {
                                        HapticFeedback.mediumImpact();
                                        _expressCashPay(ctx, state, settings);
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: dayClosed
                                      ? theme
                                            .colorScheme
                                            .surfaceContainerHighest
                                      : pos.ctaFill,
                                  foregroundColor: dayClosed
                                      ? theme.colorScheme.onSurfaceVariant
                                      : pos.ctaOnFill,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  minimumSize: Size(0, pos.ctaMinHeight - 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  dayClosed
                                      ? Icons.lock_outline
                                      : Icons.payments_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  dayClosed
                                      ? context.l10n.checkoutButton
                                      : context.l10n.payAmount(amountLabel),
                                  style: const TextStyle(
                                    fontFamily: 'NotoSansThai',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
