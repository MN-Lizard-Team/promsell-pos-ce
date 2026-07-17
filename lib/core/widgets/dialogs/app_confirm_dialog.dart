import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_dialog_shell.dart';

/// Redesigned binary confirmation (centered icon, twin pills, accent CTA).
///
/// Prefer this over [showConfirmationDialog] in new code. Existing call sites
/// keep working via the thin adapter in `confirmation_dialog.dart`.
Future<bool> showAppConfirm(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,

  /// Emphasized line under the title (e.g. item name).
  String? detail,

  /// Muted meta under [detail] (e.g. quantity).
  String? footnote,
  bool destructive = false,
  bool barrierDismissible = false,

  /// Icon for the large circular header (and preferred over button icons).
  IconData? confirmIcon,
  IconData? icon,
}) async {
  final materialCancel =
      cancelLabel ?? MaterialLocalizations.of(context).cancelButtonLabel;
  final tone = destructive ? DialogTone.destructive : DialogTone.primary;
  final headerIcon =
      icon ??
      confirmIcon ??
      (destructive ? Icons.delete_outline_rounded : Icons.help_outline_rounded);

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final cs = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;

      // Twin pills: soft cancel + solid accent confirm (design mockup).
      const actionRadius = BorderRadius.all(Radius.circular(12));

      final cancelStyle = FilledButton.styleFrom(
        backgroundColor: isDark
            ? cs.surfaceContainerHighest
            : const Color(0xFFF1F5F9),
        foregroundColor: cs.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(borderRadius: actionRadius),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      );

      final confirmStyle = FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(borderRadius: actionRadius),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      );

      final cancelButton = FilledButton(
        onPressed: () => Navigator.pop(ctx, false),
        style: cancelStyle,
        child: Text(materialCancel),
      );

      final confirmButton = FilledButton(
        onPressed: () => Navigator.pop(ctx, true),
        style: confirmStyle,
        child: Text(confirmLabel),
      );

      return AppDialogShell(
        title: title,
        message: message.trim().isEmpty ? null : message,
        detail: detail,
        footnote: footnote,
        icon: headerIcon,
        tone: tone,
        actions: [
          Semantics(button: true, label: materialCancel, child: cancelButton),
          Semantics(button: true, label: confirmLabel, child: confirmButton),
        ],
      );
    },
  );

  return result ?? false;
}
