import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DraftCreateDialog {
  DraftCreateDialog._();

  static Future<String?> show(BuildContext context, AppLocalizations l10n) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.newDraft),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.draftNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
              Navigator.pop(context, name);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
