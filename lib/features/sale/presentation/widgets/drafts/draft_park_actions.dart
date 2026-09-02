import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_bill_switch_guard.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/pos_bill_name_dialog.dart';

/// Shared park / new-bill actions for cart footer, catalog, and drafts sheet.
abstract final class DraftParkActions {
  static Future<bool> _awaitDraftOp(
    DraftBloc draftBloc, {
    required String op,
    required int startNonce,
  }) async {
    try {
      final next = await draftBloc.stream
          .firstWhere(
            (s) =>
                s.opNonce > startNonce &&
                s.lastOp == op &&
                (s.opStatus == DraftOpStatus.success ||
                    s.opStatus == DraftOpStatus.failure),
          )
          .timeout(const Duration(seconds: 8));
      return next.opStatus == DraftOpStatus.success;
    } catch (_) {
      return false;
    }
  }

  static void _showDraftError(BuildContext context, DraftBloc draftBloc) {
    final l10n = context.l10n;
    final raw = draftBloc.state.errorMessage;
    if (raw == DraftBillSwitchGuard.errorCode || raw == 'paymentInProgress') {
      AppSnackBar.warning(context, l10n.cartPaymentInProgress);
      return;
    }
    if (raw == 'tableAlreadyBound') {
      AppSnackBar.error(context, l10n.tableAlreadyBound);
      return;
    }
    if (raw != null && raw.startsWith('maxDraftsReached:')) {
      final n = int.tryParse(raw.split(':').last) ?? 0;
      AppSnackBar.error(context, l10n.maxDraftsReached(n));
      // Recover: open open-bills list so cashier can delete/manage.
      if (context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) SavedBillsPage.open(context);
        });
      }
    } else {
      AppSnackBar.error(context, l10n.errorOccurred);
    }
  }

  static bool _isPaymentBlocked(BuildContext context) {
    final cart = context.read<CartBloc>().state;
    CheckoutState? checkout;
    try {
      checkout = context.read<CheckoutBloc>().state;
    } catch (_) {}
    return DraftBillSwitchGuard.isBlockedFromStates(
      cart: cart,
      checkout: checkout,
    );
  }

  /// Optional name for the **parked** bill.
  /// Returns `null` if cancelled; empty string = park without renaming.
  static Future<String?> _promptParkName(BuildContext context) async {
    final l10n = context.l10n;
    final current = context.read<DraftBloc>().state.activeDraftName?.trim();
    final cart = context.read<CartBloc>().state;
    final contextLine = cart.isEmpty
        ? null
        : '${cart.itemCount} ${l10n.itemsLabel}';
    return PosBillNameDialog.show(
      context,
      title: l10n.parkBillNameTitle,
      hint: l10n.draftNameHint,
      confirmLabel: l10n.parkBill,
      initialName: current ?? '',
      contextLine: contextLine,
    );
  }

  /// Park current bill: confirm → save → new empty draft → clear cart on success.
  ///
  /// Default asks [showAppConfirm] first ([confirm] true) so accidental park
  /// does not empty the live cart without intent. Long-press still opens the
  /// name sheet first ([promptForName]); cancelling either step aborts.
  /// Name policy: keep existing if set; auto-name when blank
  /// ([DraftNaming.resolveParkName]). Returns true if cart was cleared.
  static Future<bool> parkCurrentBill(
    BuildContext context, {
    bool showSuccessSnack = true,
    bool promptForName = false,
    bool confirm = true,
    String? name,
  }) async {
    final l10n = context.l10n;
    final cart = context.read<CartBloc>().state;
    if (cart.isEmpty) {
      AppSnackBar.info(context, l10n.cartEmpty);
      return false;
    }
    if (_isPaymentBlocked(context)) {
      AppSnackBar.warning(context, l10n.cartPaymentInProgress);
      return false;
    }

    // name == null + no prompt → keep existing / auto in bloc.
    // prompt or explicit [name] → always pass String ('' = force auto).
    String? parkNameArg;
    if (promptForName && name == null) {
      final entered = await _promptParkName(context);
      if (entered == null) return false; // cancelled name sheet
      if (!context.mounted) return false;
      parkNameArg = entered; // may be ''
    } else if (name != null) {
      parkNameArg = name.trim();
    }

    // Confirm after optional name so cashier sees what they named.
    // Skip when [confirm] false (tests / scripted park).
    if (confirm) {
      final draftName = context.read<DraftBloc>().state.activeDraftName?.trim();
      final detail = (parkNameArg != null && parkNameArg.trim().isNotEmpty)
          ? parkNameArg.trim()
          : (draftName != null && draftName.isNotEmpty ? draftName : null);
      final confirmed = await showAppConfirm(
        context,
        title: l10n.parkBillConfirmTitle,
        message: l10n.parkBillConfirmMessage,
        confirmLabel: l10n.parkBill,
        cancelLabel: l10n.cancel,
        detail: detail,
        footnote: '${cart.itemCount} ${l10n.itemsLabel}',
        icon: Icons.pause_circle_outline,
      );
      if (!confirmed) return false;
      if (!context.mounted) return false;
    }

    final draftBloc = context.read<DraftBloc>();
    if (draftBloc.state.isBusy) return false;
    final start = draftBloc.state.opNonce;
    draftBloc.add(DraftParkRequested(cart, name: parkNameArg));
    final ok = await _awaitDraftOp(draftBloc, op: 'park', startNonce: start);
    if (!context.mounted) return false;
    if (!ok) {
      _showDraftError(context, draftBloc);
      return false;
    }
    context.read<CartBloc>().add(const CartCleared(force: true));
    // Counter feedback: light haptic + success snack (respects OS reduce-motion
    // for system haptics; no heavy animation that blocks the next tap).
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!reduceMotion) {
      HapticFeedback.mediumImpact();
    }
    if (showSuccessSnack) {
      AppSnackBar.success(context, l10n.billParked);
    }
    return true;
  }

  /// Start a new empty bill (optional [name]).
  ///
  /// Null/empty [name] → bloc auto-names via [DraftNaming.forNewEmptyBill].
  /// If the current bill has items, this is park-and-next (confirm once).
  /// Prefer [parkCurrentBill] for the primary counter action.
  static Future<bool> startNewBill(
    BuildContext context, {
    String? name,
    bool confirmIfNotEmpty = true,
    bool showSuccessSnack = true,
  }) async {
    final l10n = context.l10n;
    final cart = context.read<CartBloc>().state;
    if (_isPaymentBlocked(context)) {
      AppSnackBar.warning(context, l10n.cartPaymentInProgress);
      return false;
    }
    if (cart.isEmpty) {
      final trimmed = name?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        // Already on an empty bill — nothing to start.
        AppSnackBar.info(context, l10n.cartEmpty);
        return false;
      }
      // Named create on empty cart: rename active in place (no orphan empty).
      final draftBloc = context.read<DraftBloc>();
      final activeId = draftBloc.state.activeDraftId;
      if (activeId == null || draftBloc.state.isBusy) return false;
      final locked = cart.paymentLocked;
      final start = draftBloc.state.opNonce;
      draftBloc.add(
        DraftRenamed(draftId: activeId, name: trimmed, paymentLocked: locked),
      );
      final ok = await _awaitDraftOp(
        draftBloc,
        op: 'rename',
        startNonce: start,
      );
      if (!context.mounted) return false;
      if (!ok) {
        _showDraftError(context, draftBloc);
        return false;
      }
      if (showSuccessSnack) {
        AppSnackBar.success(context, l10n.newBillStarted);
      }
      return true;
    }
    if (confirmIfNotEmpty && !cart.isEmpty) {
      // Global confirm chrome (AppDialogShell) — not a raw AlertDialog.
      final confirmed = await showAppConfirm(
        context,
        title: l10n.parkAndNext,
        message: l10n.newBillConfirm,
        confirmLabel: l10n.confirm,
        cancelLabel: l10n.cancel,
        icon: Icons.pause_circle_outline,
      );
      if (!confirmed) return false;
      if (!context.mounted) return false;
    }
    final draftBloc = context.read<DraftBloc>();
    if (draftBloc.state.isBusy) return false;
    final start = draftBloc.state.opNonce;
    final trimmed = name?.trim();
    draftBloc.add(
      DraftStartNewBillRequested(
        cart,
        name: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      ),
    );
    final ok = await _awaitDraftOp(draftBloc, op: 'newBill', startNonce: start);
    if (!context.mounted) return false;
    if (!ok) {
      _showDraftError(context, draftBloc);
      return false;
    }
    context.read<CartBloc>().add(const CartCleared(force: true));
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (!reduceMotion) {
      HapticFeedback.lightImpact();
    }
    if (showSuccessSnack) {
      AppSnackBar.success(context, l10n.newBillStarted);
    }
    return true;
  }
}
