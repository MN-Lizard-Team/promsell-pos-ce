import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';

/// Binary confirmation dialog (compat API).
///
/// Prefer [showAppConfirm] for new code. Forwards optional [detail]/[footnote]
/// into the redesigned shell.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  String? detail,
  String? footnote,
  bool destructive = false,
  bool barrierDismissible = false,
  IconData? confirmIcon,
}) {
  return showAppConfirm(
    context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    cancelLabel: cancelLabel,
    detail: detail,
    footnote: footnote,
    destructive: destructive,
    barrierDismissible: barrierDismissible,
    confirmIcon: confirmIcon,
  );
}
