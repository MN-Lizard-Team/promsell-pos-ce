import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class ShopInfoForm extends StatelessWidget {
  const ShopInfoForm({
    required this.initialShopName,
    required this.initialAddress,
    required this.initialPhone,
    required this.onSave,
    super.key,
  });

  final String initialShopName;
  final String initialAddress;
  final String initialPhone;
  final ValueChanged<({String shopName, String address, String phone})> onSave;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10, top: 8),
          child: Text(
            'Details'.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: st.mutedText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontSize: 13,
            ),
          ),
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
              _buildShopNameTile(context),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildAddressTile(context),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildPhoneTile(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShopNameTile(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final preview = initialShopName.isEmpty ? '—' : initialShopName;

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
      onTap: () => _showShopNameDialog(context),
    );
  }

  void _showShopNameDialog(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: initialShopName);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsShopName),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: TextFormField(
              controller: ctrl,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                HapticFeedback.lightImpact();
                onSave((
                  shopName: ctrl.text.trim(),
                  address: initialAddress,
                  phone: initialPhone,
                ));
                Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final preview = initialAddress.isEmpty ? '—' : initialAddress;

    return ListTile(
      leading: Icon(Icons.location_on_outlined, color: st.softAccent, size: 22),
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
    );
  }

  void _showAddressDialog(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: initialAddress);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsAddress),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: TextFormField(
              controller: ctrl,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                HapticFeedback.lightImpact();
                onSave((
                  shopName: initialShopName,
                  address: ctrl.text.trim(),
                  phone: initialPhone,
                ));
                Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTile(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final displayPhone = _formatPhone(initialPhone);
    final preview = displayPhone.isEmpty ? '—' : displayPhone;

    return ListTile(
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
    );
  }

  void _showPhoneDialog(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: _formatPhone(initialPhone));
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsPhone),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: TextFormField(
              controller: ctrl,
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                HapticFeedback.lightImpact();
                onSave((
                  shopName: initialShopName,
                  address: initialAddress,
                  phone: ctrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim(),
                ));
                Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
}
