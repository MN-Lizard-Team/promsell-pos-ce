import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_dialog_shell.dart';
import 'package:promsell_pos_ce/core/widgets/layout/adaptive_breakpoints.dart';

enum UnsavedDialogAction { discard, cancel, save }

/// Three-way unsaved-exit dialog on [AppDialogShell].
Future<UnsavedDialogAction> showAppUnsaved(
  BuildContext context, {
  required String title,
  required String message,
  required String discardLabel,
  required String cancelLabel,
  required String saveLabel,
}) async {
  final result = await showDialog<UnsavedDialogAction>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final cs = theme.colorScheme;
      final isDark = theme.brightness == Brightness.dark;
      final compact = AdaptiveBreakpoints.isCompact(ctx);

      const actionRadius = BorderRadius.all(Radius.circular(12));

      final softStyle = FilledButton.styleFrom(
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

      final saveStyle = FilledButton.styleFrom(
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

      final discardBtn = FilledButton(
        onPressed: () => Navigator.pop(ctx, UnsavedDialogAction.discard),
        style: softStyle,
        child: Text(discardLabel),
      );
      final cancelBtn = FilledButton(
        onPressed: () => Navigator.pop(ctx, UnsavedDialogAction.cancel),
        style: softStyle,
        child: Text(cancelLabel),
      );
      final saveBtn = FilledButton(
        onPressed: () => Navigator.pop(ctx, UnsavedDialogAction.save),
        style: saveStyle,
        child: Text(saveLabel),
      );

      // Shell lays actions in one Row of Expanded children.
      // Compact: single Column action so save stacks above discard|cancel.
      final List<Widget> actions;
      if (compact) {
        actions = [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              saveBtn,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: discardBtn),
                  const SizedBox(width: 12),
                  Expanded(child: cancelBtn),
                ],
              ),
            ],
          ),
        ];
      } else {
        actions = [discardBtn, cancelBtn, saveBtn];
      }

      return AppDialogShell(
        title: title,
        message: message,
        icon: Icons.edit_note_rounded,
        tone: DialogTone.primary,
        actions: actions,
      );
    },
  );

  return result ?? UnsavedDialogAction.cancel;
}
