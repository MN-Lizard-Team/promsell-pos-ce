import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/bill_meta_chip_strip.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_more_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_footer.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/bill_note_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

enum CartMenuAction { drafts, discount, clear }

/// Live bill review — **full-bleed paper ticket** (rail + lines + settle).
///
/// No floating mid-screen card: paper runs edge-to-edge under AppBar into footer.
class CartReviewBody extends StatelessWidget {
  const CartReviewBody({super.key});

  static void showCartDiscount(BuildContext context, CartState state) {
    final settings = context.read<SettingsCubit>().state.settings;
    DiscountDialog.showCartDiscount(
      context,
      title: context.l10n.cartDiscount,
      currency: settings.currency,
      initialType: state.cartDiscountType ?? settings.defaultDiscountType,
      initialValue: state.cartDiscountValue,
      maxPercent: settings.maxDiscountPercent,
      maxAmount: settings.maxDiscountAmount.value,
      presetValues: settings.activeDiscountPreset.values,
      presetType: settings.activeDiscountPreset.type,
      onApply: (type, value) => context.read<CartBloc>().add(
        CartDiscountChanged(discountType: type, discountValue: value),
      ),
      onClear: () => context.read<CartBloc>().add(const CartDiscountCleared()),
    );
  }

  static Future<void> showCartNote(BuildContext context, CartState state) {
    final cartBloc = context.read<CartBloc>();
    return BillNoteSheet.show(
      context,
      initialValue: state.note,
      onSave: (note) => cartBloc.add(CartNoteChanged(note)),
    );
  }

  static Future<void> clearCart(BuildContext context, CartState state) async {
    if (state.isEmpty) return;
    // Mid-pay clear would drop lock and desync freeze vs live cart.
    if (CartLineActions.isPaymentLocked(context)) {
      AppSnackBar.warning(context, context.l10n.cartPaymentInProgress);
      return;
    }
    final confirmed = await showConfirmationDialog(
      context,
      title: context.l10n.clearCart,
      message: context.l10n.confirmClearCart,
      confirmLabel: context.l10n.clearCart,
      cancelLabel: context.l10n.cancel,
      destructive: true,
      confirmIcon: Icons.remove_shopping_cart_outlined,
    );
    if (!confirmed || !context.mounted) return;
    if (CartLineActions.isPaymentLocked(context)) {
      AppSnackBar.warning(context, context.l10n.cartPaymentInProgress);
      return;
    }
    final restore = CartRestored.fromCartState(state);
    context.read<CartBloc>().add(const CartCleared());
    AppSnackBar.withAction(
      context,
      context.l10n.clearCart,
      actionLabel: context.l10n.undo,
      onAction: () => context.read<CartBloc>().add(restore),
    );
  }

  static void handleMenuAction(
    BuildContext context,
    CartMenuAction action,
    CartState state,
  ) {
    switch (action) {
      case CartMenuAction.drafts:
        SavedBillsPage.open(context);
      case CartMenuAction.discount:
        showCartDiscount(context, state);
      case CartMenuAction.clear:
        clearCart(context, state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocBuilder<CartBloc, CartState>(
      builder: (_, state) {
        final items = state.items;
        final paymentLocked = CartLineActions.isPaymentLocked(context);
        final pos = context.posTheme;
        final enableItemDiscount = context
            .read<SettingsCubit>()
            .state
            .settings
            .enableItemDiscount;

        Widget lineCard(CartItem item) {
          void openMore() => CartLineMoreActions.show(
            context,
            enableDiscount: enableItemDiscount,
            onDiscount: () => CartLineActions.showItemDiscount(context, item),
            onNote: () => CartLineActions.showItemNote(context, item),
            onDuplicate: () => CartLineActions.duplicateItem(context, item),
            onRemove: () => CartLineActions.removeItem(context, item),
            item: item,
            currency: currency,
          );

          return RepaintBoundary(
            key: ValueKey(item.lineId),
            child: CartItemCard(
              item: item,
              currency: currency,
              enabled: !paymentLocked,
              onImageTap: paymentLocked
                  ? () {}
                  : () => CartLineActions.showImage(context, item),
              onRowTap: paymentLocked
                  ? () {}
                  : () => CartLineActions.openDetail(context, item),
              onLongPress: paymentLocked ? null : openMore,
              onDecrement: paymentLocked
                  ? () {}
                  : () => CartLineActions.changeQty(context, item, -1),
              onIncrement: paymentLocked
                  ? () {}
                  : () => CartLineActions.changeQty(context, item, 1),
              onDelete: paymentLocked
                  ? () {}
                  : () => CartLineActions.removeItem(context, item),
              onMoreActions: paymentLocked
                  ? null
                  : CartLineMoreActions(
                      enableDiscount: enableItemDiscount,
                      onDiscount: () =>
                          CartLineActions.showItemDiscount(context, item),
                      onNote: () => CartLineActions.showItemNote(context, item),
                      onDuplicate: () =>
                          CartLineActions.duplicateItem(context, item),
                      onRemove: () => CartLineActions.removeItem(context, item),
                      item: item,
                      currency: currency,
                    ),
            ),
          );
        }

        // Full-bleed paper → footer (no left edge rail, no floating card).
        return ColoredBox(
          color: pos.billStubPaper,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CartLineActions.paymentLockBanner(context),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 6),
                      child: BillMetaChipStrip(),
                    ),
                    Divider(height: 1, thickness: 1, color: pos.billStubBorder),
                    if (state.isEmpty)
                      Expanded(
                        child: AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: context.l10n.tapProductToAdd,
                          message: context.l10n.cartTitle,
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 8),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            indent: 76,
                            color: pos.billStubBorder,
                          ),
                          itemBuilder: (_, index) => lineCard(items[index]),
                        ),
                      ),
                  ],
                ),
              ),
              const CartReviewFooter(),
            ],
          ),
        );
      },
    );
  }
}
