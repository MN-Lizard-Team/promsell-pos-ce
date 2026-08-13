import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Product delete confirm — title question + product name as [detail].
Future<bool> showConfirmDeleteDialog(BuildContext context, String productName) {
  final l10n = context.l10n;
  return showAppConfirm(
    context,
    title: l10n.deleteProductConfirmTitle,
    message: '',
    detail: productName,
    confirmLabel: l10n.delete,
    cancelLabel: l10n.cancel,
    destructive: true,
    confirmIcon: TablerIcons.trash,
  );
}
