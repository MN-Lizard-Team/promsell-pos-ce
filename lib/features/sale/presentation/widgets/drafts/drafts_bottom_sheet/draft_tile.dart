import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
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
      child: ListTile(
        leading: Icon(
          Icons.receipt_outlined,
          color: isActive ? theme.colorScheme.primary : null,
        ),
        title: Text(
          isActive ? '$displayName (${l10n.activeDraftLabel})' : displayName,
          style: isActive
              ? TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : null,
        ),
        subtitle: Text(
          '$itemCount ${l10n.itemsLabel} · '
          '$currency${total.toStringAsFixed(2)}'
          '${updatedAt != null ? ' · ${_timeAgo(updatedAt!)}' : ''}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onRename != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: l10n.renameDraft,
                onPressed: () => _showRenameDialog(context, displayName),
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
        onTap: onSwitch,
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

  void _showRenameDialog(BuildContext context, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.renameDraft),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: context.l10n.draftNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onRename?.call(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteDraft),
        content: Text(context.l10n.deleteDraftConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.deleteDraft),
          ),
        ],
      ),
    );
  }
}
