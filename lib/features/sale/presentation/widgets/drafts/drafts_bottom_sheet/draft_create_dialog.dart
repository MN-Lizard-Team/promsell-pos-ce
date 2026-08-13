import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/pos_bill_name_dialog.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DraftCreateDialog {
  DraftCreateDialog._();

  /// Optional custom name for new bill (long-press + on Open bills).
  ///
  /// null = cancel; empty string = let bloc auto-name; else trimmed custom.
  static Future<String?> show(BuildContext context, AppLocalizations l10n) {
    return PosBillNameDialog.show(
      context,
      title: l10n.newDraft,
      hint: l10n.draftNameHint,
      confirmLabel: l10n.save,
    );
  }
}
