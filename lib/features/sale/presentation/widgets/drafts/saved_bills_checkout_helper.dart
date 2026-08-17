import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_bill_switch_guard.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Orchestrates draft switching and bill payment navigation for
/// [SavedBillsPage].
///
/// Extracted from the god-file `saved_bills_page.dart` to isolate the
/// complex async flows (bloc stream waiting, timeout handling, cart-ready
/// checks) from the widget's presentation logic.
///
/// All [BuildContext] uses after async gaps are guarded by [isMounted]
/// callbacks and [AppSnackBar] internally checks `context.mounted`. The
/// `use_build_context_synchronously` lints are suppressed because the
/// analyzer cannot verify the [isMounted] callback.
class SavedBillsCheckoutHelper {
  SavedBillsCheckoutHelper._();

  /// Switches to [draftId]. Returns `true` on success.
  ///
  /// Waits for the [DraftBloc] stream to emit a success/failure state with
  /// an incremented [DraftState.opNonce]. Pops the navigator on success
  /// unless [popAfter] is `false`.
  static Future<bool> switchTo(
    BuildContext context, {
    required String draftId,
    required DraftBloc draftBloc,
    required CartBloc cartBloc,
    required bool Function() isMounted,
    bool popAfter = true,
  }) async {
    final l10n = context.l10n;
    if (_isPaymentBlocked(cartBloc, context)) {
      AppSnackBar.warning(context, l10n.cartPaymentInProgress);
      return false;
    }
    final locked = cartBloc.state.paymentLocked;
    if (draftBloc.state.activeDraftId != draftId) {
      final startNonce = draftBloc.state.opNonce;
      draftBloc.add(
        DraftSwitched(draftId, paymentLocked: locked, liveCart: cartBloc.state),
      );
      try {
        final next = await draftBloc.stream
            .firstWhere(
              (s) =>
                  s.opNonce > startNonce &&
                  s.lastOp == 'switch' &&
                  (s.opStatus == DraftOpStatus.success ||
                      s.opStatus == DraftOpStatus.failure),
            )
            .timeout(const Duration(seconds: 8));
        if (next.opStatus != DraftOpStatus.success ||
            next.activeDraftId != draftId) {
          if (isMounted()) {
            // ignore: use_build_context_synchronously
            if (next.errorMessage == DraftBillSwitchGuard.errorCode) {
              // ignore: use_build_context_synchronously
              AppSnackBar.warning(context, l10n.cartPaymentInProgress);
            } else {
              // ignore: use_build_context_synchronously
              AppSnackBar.error(context, l10n.errorOccurred);
            }
          }
          return false;
        }
      } catch (e, stack) {
        AppLogger.warning(
          'SavedBillsCheckoutHelper.switchTo timeout/error',
          error: e,
          stack: stack,
        );
        if (isMounted()) {
          // ignore: use_build_context_synchronously
          AppSnackBar.error(context, l10n.errorOccurred);
        }
        return false;
      }
    }
    if (!isMounted()) return false;
    // ignore: use_build_context_synchronously
    if (popAfter) Navigator.maybePop(context);
    return true;
  }

  /// Pays [draft]: switches to it (if needed), waits for cart to reflect
  /// the draft, then navigates to checkout.
  static Future<void> payBill(
    BuildContext context, {
    required DraftCart draft,
    required DraftBloc draftBloc,
    required CartBloc cartBloc,
    required CheckoutBloc checkoutBloc,
    required SettingsCubit settingsCubit,
    required bool Function() isMounted,
  }) async {
    final l10n = context.l10n;
    final nav = Navigator.of(context);
    if (draft.itemCount <= 0) return;
    if (_isPaymentBlocked(cartBloc, context)) {
      AppSnackBar.warning(context, l10n.cartPaymentInProgress);
      return;
    }
    final locked = cartBloc.state.paymentLocked;

    if (draftBloc.state.activeDraftId != draft.id) {
      final startNonce = draftBloc.state.opNonce;
      draftBloc.add(
        DraftSwitched(
          draft.id,
          paymentLocked: locked,
          liveCart: cartBloc.state,
        ),
      );
      try {
        final next = await draftBloc.stream
            .firstWhere(
              (s) =>
                  s.opNonce > startNonce &&
                  s.lastOp == 'switch' &&
                  (s.opStatus == DraftOpStatus.success ||
                      s.opStatus == DraftOpStatus.failure),
            )
            .timeout(const Duration(seconds: 8));
        if (next.opStatus != DraftOpStatus.success ||
            next.activeDraftId != draft.id ||
            next.loadedDraft?.id != draft.id) {
          if (isMounted()) {
            // ignore: use_build_context_synchronously
            if (next.errorMessage == DraftBillSwitchGuard.errorCode) {
              // ignore: use_build_context_synchronously
              AppSnackBar.warning(context, l10n.cartPaymentInProgress);
            } else {
              // ignore: use_build_context_synchronously
              AppSnackBar.error(context, l10n.errorOccurred);
            }
          }
          return;
        }
      } catch (e, stack) {
        AppLogger.warning(
          'SavedBillsCheckoutHelper.payBill switch timeout/error',
          error: e,
          stack: stack,
        );
        if (isMounted()) {
          // ignore: use_build_context_synchronously
          AppSnackBar.error(context, l10n.errorOccurred);
        }
        return;
      }
    }

    // Always wait until cart reflects this draft (never assume non-empty = ready).
    final targetItemCount = draft.itemCount;
    bool cartLooksReady(c) =>
        !c.paymentLocked &&
        c.itemCount == targetItemCount &&
        (targetItemCount == 0 || !c.isEmpty);

    if (!cartLooksReady(cartBloc.state)) {
      try {
        await cartBloc.stream
            .firstWhere(cartLooksReady)
            .timeout(const Duration(seconds: 8));
      } catch (e, stack) {
        AppLogger.warning(
          'SavedBillsCheckoutHelper.payBill cart-ready timeout',
          error: e,
          stack: stack,
        );
        if (isMounted()) {
          // ignore: use_build_context_synchronously
          AppSnackBar.error(context, l10n.errorOccurred);
        }
        return;
      }
    }

    if (!isMounted()) return;
    if (cartBloc.state.isEmpty && targetItemCount > 0) {
      // ignore: use_build_context_synchronously
      AppSnackBar.error(context, l10n.errorOccurred);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    nav.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!nav.mounted) return;
      navigateToCheckout(
        nav.context,
        cartBloc: cartBloc,
        checkoutBloc: checkoutBloc,
        draftBloc: draftBloc,
        settingsCubit: settingsCubit,
      );
    });
  }

  static bool _isPaymentBlocked(CartBloc cartBloc, BuildContext context) {
    try {
      final checkout = context.read<CheckoutBloc>();
      return DraftBillSwitchGuard.isBlockedFromStates(
        cart: cartBloc.state,
        checkout: checkout.state,
      );
    } catch (_) {
      return false;
    }
  }
}
