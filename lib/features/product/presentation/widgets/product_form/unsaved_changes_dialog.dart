import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_unsaved_dialog.dart';

export 'package:promsell_pos_ce/core/widgets/dialogs/app_unsaved_dialog.dart'
    show UnsavedDialogAction;

/// Unsaved-exit dialog for product form (create vs edit copy).
Future<UnsavedDialogAction> showUnsavedChangesDialog(
  BuildContext context, {
  bool isEditing = false,
}) {
  final l10n = context.l10n;
  return showAppUnsaved(
    context,
    title: l10n.unsavedChangesTitle,
    message: isEditing
        ? l10n.unsavedChangesMessageEdit
        : l10n.unsavedChangesMessageCreate,
    discardLabel: l10n.discardChanges,
    cancelLabel: l10n.cancel,
    saveLabel: l10n.save,
  );
}
