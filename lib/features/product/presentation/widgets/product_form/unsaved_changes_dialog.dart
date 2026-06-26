import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

enum UnsavedDialogAction { discard, cancel, save }

Future<UnsavedDialogAction> showUnsavedChangesDialog(
  BuildContext context,
) async {
  final l10n = context.l10n;
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.unsavedChangesTitle),
      content: Text(l10n.unsavedChangesMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'discard'),
          child: Text(l10n.discardDraft),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, 'cancel'),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, 'save'),
          child: Text(l10n.save),
        ),
      ],
    ),
  );
  return switch (result) {
    'discard' => UnsavedDialogAction.discard,
    'save' => UnsavedDialogAction.save,
    _ => UnsavedDialogAction.cancel,
  };
}
