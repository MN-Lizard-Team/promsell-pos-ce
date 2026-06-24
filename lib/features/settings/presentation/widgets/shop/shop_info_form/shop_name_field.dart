import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class ShopNameField extends StatelessWidget {
  const ShopNameField({
    super.key,
    required this.initialValue,
    required this.onSave,
  });

  final String initialValue;
  final ValueChanged<String> onSave;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final preview = initialValue.isEmpty ? '—' : initialValue;

    return ListTile(
      leading: Icon(Icons.store_outlined, color: st.softAccent, size: 22),
      title: Text(
        l10n.settingsShopName,
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
      onTap: () => _showDialog(context),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _ShopNameDialog(initialValue: initialValue, onSave: onSave),
    );
  }
}

class _ShopNameDialog extends StatefulWidget {
  const _ShopNameDialog({required this.initialValue, required this.onSave});

  final String initialValue;
  final ValueChanged<String> onSave;

  @override
  State<_ShopNameDialog> createState() => _ShopNameDialogState();
}

class _ShopNameDialogState extends State<_ShopNameDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

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
      title: Text(l10n.settingsShopName),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 280,
          child: TextFormField(
            controller: _ctrl,
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.shopNameHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            validator: (v) {
              final text = v?.trim() ?? '';
              if (text.isEmpty) return l10n.shopNameRequired;
              if (text.length > 50) return l10n.shopNameTooLong;
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              HapticFeedback.lightImpact();
              widget.onSave(_ctrl.text.trim());
              Navigator.of(context).pop();
            }
          },
          style: FilledButton.styleFrom(backgroundColor: st.softAccent),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
