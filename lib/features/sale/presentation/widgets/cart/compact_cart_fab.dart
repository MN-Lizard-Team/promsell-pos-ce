import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CompactCartFab extends StatefulWidget {
  const CompactCartFab({super.key});

  @override
  State<CompactCartFab> createState() => _CompactCartFabState();
}

class _CompactCartFabState extends State<CompactCartFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _confirmExitCompact(BuildContext ctx) {
    final l10n = ctx.l10n;
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.exitCompactMode),
        content: Text(l10n.exitCompactModeConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              final cubit = ctx.read<SettingsCubit>();
              cubit.update(
                cubit.state.settings.copyWith(ultraCompactMode: false),
              );
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final currency = settings.currency;

    return Positioned(
      bottom: 16 + MediaQuery.paddingOf(context).bottom,
      right: 16,
      child: RepaintBoundary(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Multi-bill access when mode switcher is hidden (ultra compact).
            BlocSelector<DraftBloc, DraftState, int>(
              selector: (s) => s.openBillCount,
              builder: (context, openCount) {
                final pos = context.posTheme;
                if (openCount <= 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Material(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    elevation: pos.elevFab,
                    shadowColor: pos.shadowKey.withValues(
                      alpha: pos.shadowFabNeutralAlpha,
                    ),
                    surfaceTintColor: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => SavedBillsPage.open(context),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Badge(
                          isLabelVisible: true,
                          label: Text(openCount > 99 ? '99+' : '$openCount'),
                          child: Icon(
                            Icons.folder_copy_outlined,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            BlocBuilder<CartBloc, CartState>(
              // Payable inputs only — display uses payableTotals.
              buildWhen: (prev, curr) =>
                  prev.itemCount != curr.itemCount ||
                  prev.total != curr.total ||
                  prev.itemsSubtotal != curr.itemsSubtotal ||
                  prev.cartDiscountAmount != curr.cartDiscountAmount ||
                  prev.serviceChargeAmount != curr.serviceChargeAmount ||
                  prev.promotionDiscountAmount !=
                      curr.promotionDiscountAmount ||
                  prev.serviceChargeRate != curr.serviceChargeRate ||
                  prev.cartDiscountType != curr.cartDiscountType ||
                  prev.cartDiscountValue != curr.cartDiscountValue ||
                  prev.paymentLocked != curr.paymentLocked,
              builder: (ctx, state) {
                final count = state.itemCount;
                final total = state.payableTotals(settings).payableTotal;
                final pos = ctx.posTheme;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pay (orange) — money CTA only when cart has lines.
                    if (count > 0) ...[
                      Semantics(
                        button: true,
                        label: ctx.l10n.checkoutButton,
                        child: Material(
                          color: pos.ctaFill,
                          borderRadius: BorderRadius.circular(16),
                          elevation: pos.elevFabActive,
                          shadowColor: pos.ctaFill.withValues(
                            alpha: pos.shadowFabCtaAlpha,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              navigateToCheckout(ctx);
                            },
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Icon(
                                Icons.payments_outlined,
                                color: pos.ctaOnFill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    // Cart review FAB — bag + qty (qty badge, never error red).
                    TweenAnimationBuilder<double>(
                      key: ValueKey('fab_bounce_$count'),
                      tween: Tween(begin: 1.15, end: 1.0),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: AnimatedBuilder(
                        animation: _pressController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 - (_pressController.value * 0.06),
                            child: child,
                          );
                        },
                        child: Semantics(
                          button: true,
                          label: count == 0
                              ? ctx.l10n.cartBottomLabel
                              : '${ctx.l10n.cartBottomLabel}, $count',
                          child: Material(
                            color: count == 0
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            elevation: count == 0
                                ? pos.elevFab
                                : pos.elevFabActive,
                            shadowColor: count == 0
                                ? pos.shadowKey.withValues(
                                    alpha: pos.shadowFabNeutralAlpha,
                                  )
                                : theme.colorScheme.primary.withValues(
                                    alpha: pos.shadowFabCtaAlpha,
                                  ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTapDown: (_) => _pressController.forward(),
                              onTapCancel: () => _pressController.reverse(),
                              onTap: () {
                                _pressController.reverse();
                                HapticFeedback.selectionClick();
                                openCartReviewPage(ctx);
                              },
                              onLongPress: () => _confirmExitCompact(ctx),
                              child: count == 0
                                  ? SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                        color: theme
                                            .colorScheme
                                            .onPrimaryContainer,
                                        size: 24,
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        10,
                                        14,
                                        10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Icon(
                                                Icons.shopping_bag_outlined,
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                size: 22,
                                              ),
                                              Positioned(
                                                top: -6,
                                                right: -8,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 1,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        pos.qtyBadgeBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color: theme
                                                          .colorScheme
                                                          .primary,
                                                      width: 1.25,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    '$count',
                                                    style: TextStyle(
                                                      color: pos
                                                          .qtyBadgeForeground,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 10),
                                          MoneyText(
                                            value: total.value,
                                            currency: currency,
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                  color: theme
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontFamily: 'NotoSansThai',
                                                ),
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
