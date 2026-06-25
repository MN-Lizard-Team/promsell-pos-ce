import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class ShopContactField extends StatelessWidget {
  const ShopContactField({
    super.key,
    required this.initialAddress,
    required this.initialPhone,
    required this.onSaveAddress,
    required this.onSavePhone,
  });

  final String initialAddress;
  final String initialPhone;
  final ValueChanged<String> onSaveAddress;
  final ValueChanged<String> onSavePhone;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildAddressTile(context),
        Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: context.settingsTheme.cardBorderColor,
        ),
        _buildPhoneTile(context),
      ],
    );
  }

  Widget _buildAddressTile(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final preview = initialAddress.isEmpty ? '—' : initialAddress;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(
          Icons.location_on_outlined,
          color: st.softAccent,
          size: 22,
        ),
        title: Text(
          l10n.settingsAddress,
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
        onTap: () => _showAddressDialog(context),
      ),
    );
  }

  void _showAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ShopAddressDialog(
        initialAddress: initialAddress,
        onSave: onSaveAddress,
      ),
    );
  }

  Widget _buildPhoneTile(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final displayPhone = _formatPhone(initialPhone);
    final preview = displayPhone.isEmpty ? '—' : displayPhone;

    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(Icons.phone_outlined, color: st.softAccent, size: 22),
        title: Text(
          l10n.settingsPhone,
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
        onTap: () => _showPhoneDialog(context),
      ),
    );
  }

  void _showPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _ShopPhoneDialog(initialPhone: initialPhone, onSave: onSavePhone),
    );
  }
}

class _ShopAddressDialog extends StatefulWidget {
  const _ShopAddressDialog({
    required this.initialAddress,
    required this.onSave,
  });

  final String initialAddress;
  final ValueChanged<String> onSave;

  @override
  State<_ShopAddressDialog> createState() => _ShopAddressDialogState();
}

class _ShopAddressDialogState extends State<_ShopAddressDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialAddress);
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
      title: Text(l10n.settingsAddress),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 280,
          child: TextFormField(
            controller: _ctrl,
            maxLines: 4,
            minLines: 2,
            maxLength: 200,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.addressHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            validator: (v) {
              final text = v?.trim() ?? '';
              if (text.length > 200) return l10n.addressTooLong;
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

class _ShopPhoneDialog extends StatefulWidget {
  const _ShopPhoneDialog({required this.initialPhone, required this.onSave});

  final String initialPhone;
  final ValueChanged<String> onSave;

  @override
  State<_ShopPhoneDialog> createState() => _ShopPhoneDialogState();
}

class _ShopPhoneDialogState extends State<_ShopPhoneDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _formatPhone(widget.initialPhone));
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
      title: Text(l10n.settingsPhone),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 280,
          child: TextFormField(
            controller: _ctrl,
            keyboardType: TextInputType.phone,
            maxLength: 12,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.phoneHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            validator: (v) {
              final raw = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
              if (raw.isNotEmpty && (raw.length < 9 || raw.length > 10)) {
                return l10n.phoneInvalid;
              }
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
              widget.onSave(
                _ctrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim(),
              );
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

String _formatPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length <= 3) return digits;
  if (digits.length <= 6) {
    return '${digits.substring(0, 3)}-${digits.substring(3)}';
  }
  if (digits.length <= 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6, 10)}';
}
