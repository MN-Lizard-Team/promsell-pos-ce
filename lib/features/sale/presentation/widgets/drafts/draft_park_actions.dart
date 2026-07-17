import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';

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

  /// Optional name for the **parked** bill.
  /// Returns `null` if cancelled; empty string = park without renaming.
  static Future<String?> _promptParkName(BuildContext context) async {
    final l10n = context.l10n;
    final current = context.read<DraftBloc>().state.activeDraftName?.trim();
    // Controller must live in the dialog State so dispose runs after the
    // route finishes unmounting (not immediately after pop).
    return showDialog<String>(
      context: context,
      builder: (ctx) => _ParkBillNameDialog(
        title: l10n.parkBillNameTitle,
        hint: l10n.draftNameHint,
        cancelLabel: l10n.cancel,
        confirmLabel: l10n.parkBill,
        initialName: current ?? '',
      ),
    );
  }

  /// Park current bill: save → new empty draft → clear cart on success.
  ///
  /// Default is **1-tap park** ([promptForName] false). Pass
  /// `promptForName: true` (e.g. long-press) to name the parked bill.
  /// Returns true if cart was cleared.
  static Future<bool> parkCurrentBill(
    BuildContext context, {
    bool showSuccessSnack = true,
    bool promptForName = false,
    String? name,
  }) async {
    final l10n = context.l10n;
    final cart = context.read<CartBloc>().state;
    if (cart.isEmpty) {
      AppSnackBar.info(context, l10n.cartEmpty);
      return false;
    }

    String? parkName = name?.trim();
    if (promptForName && name == null) {
      final entered = await _promptParkName(context);
      if (entered == null) return false; // cancelled
      if (!context.mounted) return false;
      parkName = entered.isEmpty ? null : entered;
    } else if (parkName != null && parkName.isEmpty) {
      parkName = null;
    }

    final draftBloc = context.read<DraftBloc>();
    if (draftBloc.state.isBusy) return false;
    final start = draftBloc.state.opNonce;
    draftBloc.add(DraftParkRequested(cart, name: parkName));
    final ok = await _awaitDraftOp(draftBloc, op: 'park', startNonce: start);
    if (!context.mounted) return false;
    if (!ok) {
      _showDraftError(context, draftBloc);
      return false;
    }
    context.read<CartBloc>().add(const CartCleared());
    if (showSuccessSnack) {
      AppSnackBar.success(context, l10n.billParked);
    }
    return true;
  }

  /// Start a new empty bill (optional [name]).
  ///
  /// If the current bill has items, this is the same as park-and-next
  /// (confirm once). Prefer [parkCurrentBill] for the primary counter action.
  static Future<bool> startNewBill(
    BuildContext context, {
    String? name,
    bool confirmIfNotEmpty = true,
    bool showSuccessSnack = true,
  }) async {
    final l10n = context.l10n;
    final cart = context.read<CartBloc>().state;
    if (cart.isEmpty && (name == null || name.isEmpty)) {
      // Already on an empty bill — nothing to start.
      AppSnackBar.info(context, l10n.cartEmpty);
      return false;
    }
    if (confirmIfNotEmpty && !cart.isEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.parkAndNext),
          content: Text(l10n.newBillConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (confirmed != true) return false;
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
    context.read<CartBloc>().add(const CartCleared());
    if (showSuccessSnack) {
      AppSnackBar.success(context, l10n.newBillStarted);
    }
    return true;
  }
}

/// Owns [TextEditingController] for the full dialog lifecycle.
class _ParkBillNameDialog extends StatefulWidget {
  const _ParkBillNameDialog({
    required this.title,
    required this.hint,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.initialName,
  });

  final String title;
  final String hint;
  final String cancelLabel;
  final String confirmLabel;
  final String initialName;

  @override
  State<_ParkBillNameDialog> createState() => _ParkBillNameDialogState();
}

class _ParkBillNameDialogState extends State<_ParkBillNameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  void _pop([String? value]) {
    unfocusForDialogClose();
    Navigator.pop(context, value);
  }

  void _submit() => _pop(_ctrl.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => _pop(), child: Text(widget.cancelLabel)),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}
