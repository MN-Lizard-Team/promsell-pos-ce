import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_shared_widgets.dart';

class ReceiptContentSection extends StatelessWidget {
  const ReceiptContentSection({
    super.key,
    required this.settings,
    required this.onUpdate,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final s = settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptSharedWidgets.buildSectionTitle(
          context,
          context.l10n.settingsSectionContent,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            children: [
              _buildNoteTile(context, s),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              ReceiptSharedWidgets.buildSwitchTile(
                context: context,
                icon: Icons.info_outline,
                title: context.l10n.settingsShowShopInfo,
                value: s.showShopInfoOnReceipt,
                onChanged: (v) =>
                    onUpdate(s.copyWith(showShopInfoOnReceipt: v)),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildPaperSizeTile(context, s),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaperSizeTile(BuildContext context, Settings s) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final label = s.receiptSize == 'A4'
        ? l10n.receiptSizeA4
        : l10n.receiptSize80mm;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(
          Icons.crop_portrait_outlined,
          color: st.softAccent,
          size: 22,
        ),
        title: Text(
          l10n.settingsReceiptSize,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: st.softAccent,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: st.softTextSecondary),
        onTap: () async {
          final next = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(l10n.receiptSize80mm),
                    trailing: s.receiptSize != 'A4'
                        ? Icon(Icons.check, color: st.softAccent)
                        : null,
                    onTap: () => Navigator.pop(ctx, '80mm'),
                  ),
                  ListTile(
                    title: Text(l10n.receiptSizeA4),
                    trailing: s.receiptSize == 'A4'
                        ? Icon(Icons.check, color: st.softAccent)
                        : null,
                    onTap: () => Navigator.pop(ctx, 'A4'),
                  ),
                ],
              ),
            ),
          );
          if (next != null && next != s.receiptSize) {
            onUpdate(s.copyWith(receiptSize: next));
          }
        },
      ),
    );
  }

  Widget _buildNoteTile(BuildContext context, Settings s) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final preview = s.receiptNote.isEmpty ? '—' : s.receiptNote;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(
          Icons.receipt_long_outlined,
          color: st.softAccent,
          size: 22,
        ),
        title: Text(
          l10n.settingsReceiptNote,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                preview,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: st.softTextSecondary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: st.softTextSecondary, size: 20),
          ],
        ),
        onTap: () => _showNoteDialog(context, s),
      ),
    );
  }

  void _showNoteDialog(BuildContext context, Settings s) {
    showDialog(
      context: context,
      builder: (_) => _NoteDialog(settings: s, onUpdate: onUpdate),
    );
  }
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.settings, required this.onUpdate});

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _ctrl = TextEditingController(text: widget.settings.receiptNote);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    return AlertDialog(
      title: Text(l10n.settingsReceiptNote),
      content: TextField(
        controller: _ctrl,
        maxLines: 5,
        minLines: 3,
        maxLength: 200,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.settingsReceiptNoteHint,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            widget.onUpdate(widget.settings.copyWith(receiptNote: _ctrl.text));
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(backgroundColor: st.softAccent),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
