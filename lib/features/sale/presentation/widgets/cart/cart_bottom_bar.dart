import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bounce_badge.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/express_cash_handler.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartBottomBar extends StatefulWidget {
  const CartBottomBar({super.key});

  /// Catalog scroll padding under this dock (row ~56 + pads + safe area).
  static double contentInset(BuildContext context) =>
      88 + MediaQuery.viewPaddingOf(context).bottom;

  @override
  State<CartBottomBar> createState() => _CartBottomBarState();
}

class _CartBottomBarState extends State<CartBottomBar>
    with SingleTickerProviderStateMixin {
  bool _bounce = false;
  Timer? _bounceTimer;

  void _triggerBounce() {
    if (!mounted) return;
    setState(() => _bounce = true);
    _bounceTimer?.cancel();
    _bounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _bounce = false);
    });
  }

  void _openReview(BuildContext context) {
    openCartReviewPage(context);
  }

  void _pay(BuildContext context) {
    navigateToCheckout(context);
  }

  @override
  void dispose() {
    _bounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.select(
      (SettingsCubit c) => c.state.settings.currency,
    );
    final dayClosed = context.select(
      (SettingsCubit c) => SalesDayLock.isCreateBlocked(
        dailyCloseLock: c.state.settings.dailyCloseLock,
        lastClosedDate: c.state.settings.lastClosedDate,
      ),
    );

    return BlocListener<CartBloc, CartState>(
      listenWhen: (prev, curr) => prev.itemCount != curr.itemCount,
      listener: (context, state) => _triggerBounce(),
      child: RepaintBoundary(
        child: BlocBuilder<CartBloc, CartState>(
          buildWhen: (prev, curr) =>
              prev.itemCount != curr.itemCount ||
              prev.total != curr.total ||
              prev.itemsSubtotal != curr.itemsSubtotal ||
              prev.cartDiscountAmount != curr.cartDiscountAmount ||
              prev.serviceChargeAmount != curr.serviceChargeAmount ||
              prev.promotionDiscountAmount != curr.promotionDiscountAmount ||
              prev.serviceChargeRate != curr.serviceChargeRate ||
              prev.cartDiscountType != curr.cartDiscountType ||
              prev.cartDiscountValue != curr.cartDiscountValue ||
              prev.paymentLocked != curr.paymentLocked,
          builder: (ctx, state) {
            final count = state.itemCount;
            final isEmpty = count == 0;
            final payable = state
                .payableTotals(context.read<SettingsCubit>().state.settings)
                .payableTotal;
            final pos = ctx.posTheme;
            final amountLabel =
                '$currency${payable.value.toStringAsFixed(payable.value == payable.value.roundToDouble() ? 0 : 2)}';
            final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;

            // Full-bleed dock — one outer shadow (PosTheme.shadowDockUp).
            final topR = pos.stickyBarRadius;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(topR)),
                boxShadow: pos.shadowDockUp,
              ),
              child: Material(
                color: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(topR)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomSafe),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) {
                      return FadeTransition(opacity: anim, child: child);
                    },
                    child: isEmpty
                        ? _CartEntryStrip(
                            key: const ValueKey('empty'),
                            semanticLabel: context.l10n.cartBottomLabel,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              _openReview(ctx);
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 22,
                                  color: theme.colorScheme.onSurfaceVariant,
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
                                      Text(
                                        context.l10n.tapProductToAdd,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                CartBounceBadge(
                                  count: 0,
                                  bounce: false,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  foregroundColor:
                                      theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 22,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          )
                        : Row(
                            key: ValueKey('bill-$count'),
                            children: [
                              Expanded(
                                child: _CartEntryStrip(
                                  semanticLabel:
                                      '${context.l10n.cartBottomLabel}, $count',
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    _openReview(ctx);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 22,
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
                                      CartBounceBadge(
                                        count: count,
                                        bounce: _bounce,
                                        backgroundColor: pos.qtyBadgeBackground,
                                        foregroundColor: pos.qtyBadgeForeground,
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 22,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Hairline between cart entry and money CTA.
                              Container(
                                width: 1,
                                height: 36,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.6),
                              ),
                              FilledButton.icon(
                                key: const ValueKey('sale-pay-cta'),
                                onPressed: dayClosed
                                    ? () {
                                        HapticFeedback.heavyImpact();
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
                                        ExpressCashHandler.pay(
                                          context: ctx,
                                          cart: state,
                                          settings: context
                                              .read<SettingsCubit>()
                                              .state
                                              .settings,
                                        );
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
                                  elevation: dayClosed
                                      ? pos.elevFlat
                                      : pos.elevPaperActive,
                                  shadowColor: pos.ctaFill.withValues(
                                    alpha: pos.shadowFabCtaAlpha,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  minimumSize: Size(0, pos.ctaMinHeight - 6),
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

/// Flat tappable cart strip inside the dock — no nested card/shadow.
class _CartEntryStrip extends StatelessWidget {
  const _CartEntryStrip({
    super.key,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: child,
          ),
        ),
      ),
    );
  }
}
