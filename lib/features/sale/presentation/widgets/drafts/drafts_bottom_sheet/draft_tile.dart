import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class DraftTile extends StatelessWidget {
  const DraftTile({
    super.key,
    required this.id,
    required this.name,
    required this.itemCount,
    required this.total,
    required this.currency,
    required this.isActive,
    this.updatedAt,
    required this.l10n,
    required this.theme,
    required this.onSwitch,
    required this.onDelete,
    required this.onRename,
    this.onPay,
  });

  final String id;
  final String? name;
  final int itemCount;
  final double total;
  final String currency;
  final bool isActive;
  final DateTime? updatedAt;
  final AppLocalizations l10n;
  final ThemeData theme;
  final VoidCallback? onSwitch;
  final VoidCallback? onDelete;
  final void Function(String)? onRename;

  /// Pay this bill (switch + checkout). Null hides the Pay control.
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final displayName = name?.isNotEmpty == true ? name! : l10n.untitledDraft;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isActive ? 1 : 0,
      color: isActive
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 12, right: 4),
                leading: Icon(
                  Icons.receipt_outlined,
                  color: isActive ? theme.colorScheme.primary : null,
                ),
                title: Text(
                  isActive
                      ? '$displayName (${l10n.activeDraftLabel})'
                      : displayName,
                  style: isActive
                      ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                subtitle: Text(
                  '$itemCount ${l10n.itemsLabel}'
                  '${updatedAt != null ? ' · ${_timeAgo(updatedAt!)}' : ''}',
                ),
                onTap: onSwitch,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                MoneyText(
                  value: total,
                  currency: currency,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'NotoSansThai',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onPay != null && itemCount > 0)
                      FilledButton.tonal(
                        onPressed: onPay,
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text(l10n.checkoutButton),
                      ),
                    if (onRename != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: l10n.renameDraft,
                        onPressed: () =>
                            _showRenameDialog(context, displayName),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: theme.colorScheme.error,
                        ),
                        tooltip: l10n.deleteDraft,
                        onPressed: () => _confirmDelete(context),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return l10n.timeAgoDays(diff.inDays);
    if (diff.inHours > 0) return l10n.timeAgoHours(diff.inHours);
    if (diff.inMinutes > 0) return l10n.timeAgoMinutes(diff.inMinutes);
    return l10n.justNow;
  }

  Future<void> _showRenameDialog(BuildContext context, String current) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (_) => _RenameDraftDialog(
        title: l10n.renameDraft,
        hint: l10n.draftNameHint,
        cancelLabel: l10n.cancel,
        saveLabel: l10n.save,
        initialName: current,
        onSave: (name) => onRename?.call(name),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: context.l10n.deleteDraft,
      message: context.l10n.deleteDraftConfirm,
      confirmLabel: context.l10n.deleteDraft,
      destructive: true,
      confirmIcon: Icons.delete_outline,
    );
    if (confirmed) {
      onDelete?.call();
    }
  }
}

/// Rename bill/draft — owns controller for the full dialog + IME lifecycle.
class _RenameDraftDialog extends StatefulWidget {
  const _RenameDraftDialog({
    required this.title,
    required this.hint,
    required this.cancelLabel,
    required this.saveLabel,
    required this.initialName,
    required this.onSave,
  });

  final String title;
  final String hint;
  final String cancelLabel;
  final String saveLabel;
  final String initialName;
  final ValueChanged<String> onSave;

  @override
  State<_RenameDraftDialog> createState() => _RenameDraftDialogState();
}

class _RenameDraftDialogState extends State<_RenameDraftDialog> {
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

  void _pop() {
    unfocusForDialogClose();
    Navigator.pop(context);
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isNotEmpty) {
      widget.onSave(name);
    }
    _pop();
  }

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
        TextButton(onPressed: _pop, child: Text(widget.cancelLabel)),
        FilledButton(onPressed: _submit, child: Text(widget.saveLabel)),
      ],
    );
  }
}
