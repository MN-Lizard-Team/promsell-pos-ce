import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SettingsTextTile extends StatelessWidget {
  const SettingsTextTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.icon,
    this.accentColor,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    super.key,
  });

  final String title;
  final String value;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final Color? accentColor;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final accent = accentColor ?? st.softAccent;

    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: icon != null
          ? Container(
              width: st.iconSize,
              height: st.iconSize,
              decoration: BoxDecoration(
                color: st.iconContainerBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 24),
            )
          : null,
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: value.isNotEmpty
          ? Text(
              value,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: st.softAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            )
          : Text(
              'Tap to set',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: st.mutedText,
                fontSize: 14,
              ),
            ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: () => _showEditDialog(context),
    );
  }

  void _showEditDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog<String>(
      context: context,
      builder: (ctx) => _EditDialog(
        title: title,
        initialValue: value,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    ).then((result) {
      if (result != null) {
        onChanged(result.trim());
      }
    });
  }
}

class _EditDialog extends StatefulWidget {
  const _EditDialog({
    required this.title,
    required this.initialValue,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
  });

  final String title;
  final String initialValue;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _dismiss({bool save = true}) {
    if (save) {
      final text = _controller.text.trim();
      if (widget.keyboardType == TextInputType.number) {
        if (text.isNotEmpty && int.tryParse(text) == null) {
          _shakeController.forward(from: 0);
          HapticFeedback.heavyImpact();
          return;
        }
      }
      Navigator.of(context).pop(text);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final offset =
                    Tween<Offset>(begin: Offset.zero, end: const Offset(8, 0))
                        .chain(CurveTween(curve: Curves.elasticIn))
                        .evaluate(_shakeController);
                return Transform.translate(offset: offset, child: child);
              },
              child: TextField(
                controller: _controller,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter ${widget.title}',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _dismiss(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _dismiss(save: false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _dismiss(),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
