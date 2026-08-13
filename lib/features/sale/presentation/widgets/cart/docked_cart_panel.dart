import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/bill_meta_chip_strip.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_more_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_body.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_footer.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Docked cart — full-bleed live ticket (same language as [CartReviewBody]).
class DockedCartPanel extends StatelessWidget {
  const DockedCartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final pos = context.posTheme;

    // Side ticket pane — paperActive lift (not freestyle elev 2).
    return Material(
      elevation: pos.elevPaperActive,
      shadowColor: pos.shadowKey.withValues(alpha: pos.shadowDockFarAlpha),
      surfaceTintColor: Colors.transparent,
      color: pos.billStubPaper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) =>
                p.isEmpty != c.isEmpty || p.paymentLocked != c.paymentLocked,
            builder: (context, cartState) {
              final locked = CartLineActions.isPaymentLocked(context);
              return Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 20,
                    color: pos.activeBillRail,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BlocBuilder<DraftBloc, DraftState>(
                      buildWhen: (p, c) =>
                          p.activeDraftName != c.activeDraftName ||
                          p.openBillCount != c.openBillCount,
                      builder: (context, draft) {
                        final name = draft.activeDraftName?.trim();
                        final title = (name != null && name.isNotEmpty)
                            ? context.l10n.cartActiveBill(name)
                            : context.l10n.cartTitle;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            if (draft.openBillCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: InkWell(
                                  key: const ValueKey(
                                    'sale_dock_open_bills_chip',
                                  ),
                                  onTap: locked
                                      ? null
                                      : () => SavedBillsPage.open(context),
                                  child: Text(
                                    context.l10n.openBillsCount(
                                      draft.openBillCount,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: pos.parkCtaForeground,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  if (!cartState.isEmpty && !locked)
                    TextButton(
                      key: const ValueKey('sale_dock_clear_cta'),
                      onPressed: () =>
                          CartReviewBody.clearCart(context, cartState),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        context.l10n.clearCart,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  IconButton(
                    key: const ValueKey('sale_dock_drafts_cta'),
                    tooltip: context.l10n.draftsTitle,
                    icon: const Icon(Icons.receipt_long_outlined),
                    onPressed: locked
                        ? null
                        : () => CartReviewBody.handleMenuAction(
                            context,
                            CartMenuAction.drafts,
                            cartState,
                          ),
                  ),
                ],
              );
            },
          ),
          Divider(height: 1, color: pos.billStubBorder),
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) => p.paymentLocked != c.paymentLocked,
            builder: (context, _) {
              try {
                return BlocBuilder<CheckoutBloc, CheckoutState>(
                  buildWhen: (p, c) => p.status != c.status,
                  builder: (context, _) =>
                      CartLineActions.paymentLockBanner(context),
                );
              } catch (_) {
                return CartLineActions.paymentLockBanner(context);
              }
            },
          ),
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              buildWhen: (prev, curr) =>
                  prev.items != curr.items ||
                  prev.paymentLocked != curr.paymentLocked,
              builder: (context, state) {
                final paymentLocked = CartLineActions.isPaymentLocked(context);
                final enableItemDiscount = context
                    .read<SettingsCubit>()
                    .state
                    .settings
                    .enableItemDiscount;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 4),
                      child: BillMetaChipStrip(),
                    ),
                    Divider(height: 1, color: pos.billStubBorder),
                    if (state.isEmpty)
                      Expanded(
                        child: AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: context.l10n.cartEmpty,
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: 76,
                            color: pos.billStubBorder,
                          ),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            void openMore() => CartLineMoreActions.show(
                              context,
                              enableDiscount: enableItemDiscount,
                              onDiscount: () =>
                                  CartLineActions.showItemDiscount(
                                    context,
                                    item,
                                  ),
                              onNote: () =>
                                  CartLineActions.showItemNote(context, item),
                              onDuplicate: () =>
                                  CartLineActions.duplicateItem(context, item),
                              onRemove: () =>
                                  CartLineActions.removeItem(context, item),
                              item: item,
                              currency: currency,
                            );
                            return CartItemCard(
                              item: item,
                              currency: currency,
                              enabled: !paymentLocked,
                              onImageTap: paymentLocked
                                  ? () {}
                                  : () => CartLineActions.showImage(
                                      context,
                                      item,
                                    ),
                              onRowTap: paymentLocked
                                  ? () {}
                                  : () => CartLineActions.openDetail(
                                      context,
                                      item,
                                    ),
                              onLongPress: paymentLocked ? null : openMore,
                              onDecrement: paymentLocked
                                  ? () {}
                                  : () => CartLineActions.changeQty(
                                      context,
                                      item,
                                      -1,
                                    ),
                              onIncrement: paymentLocked
                                  ? () {}
                                  : () => CartLineActions.changeQty(
                                      context,
                                      item,
                                      1,
                                    ),
                              onDelete: paymentLocked
                                  ? () {}
                                  : () => CartLineActions.removeItem(
                                      context,
                                      item,
                                    ),
                              onMoreActions: paymentLocked
                                  ? null
                                  : CartLineMoreActions(
                                      enableDiscount: enableItemDiscount,
                                      onDiscount: () =>
                                          CartLineActions.showItemDiscount(
                                            context,
                                            item,
                                          ),
                                      onNote: () =>
                                          CartLineActions.showItemNote(
                                            context,
                                            item,
                                          ),
                                      onDuplicate: () =>
                                          CartLineActions.duplicateItem(
                                            context,
                                            item,
                                          ),
                                      onRemove: () =>
                                          CartLineActions.removeItem(
                                            context,
                                            item,
                                          ),
                                      item: item,
                                      currency: currency,
                                    ),
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const CartReviewFooter(),
        ],
      ),
    );
  }
}
