import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class PromptpayBillerIdTile extends StatelessWidget {
  const PromptpayBillerIdTile({
    super.key,
    required this.settings,
    required this.cubit,
    required this.st,
    required this.l10n,
  });

  final Settings settings;
  final SettingsCubit cubit;
  final SettingsThemeExtension st;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hasId = settings.billerId.isNotEmpty;

    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.receipt_long_outlined,
          color: st.softAccent,
          size: 24,
        ),
      ),
      title: Text(
        l10n.settingsBillerId,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        hasId ? settings.billerId : l10n.settingsBillerIdHint,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: hasId ? st.softAccent : st.mutedText,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: () => _showBillerIdDialog(context),
    );
  }

  void _showBillerIdDialog(BuildContext context) {
    final ctrl = TextEditingController(text: settings.billerId);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsBillerId),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 15,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.settingsBillerIdHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                if (clean.length != 13 && clean.length != 15) {
                  return 'Must be 13 or 15 digits';
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
                final raw = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
                cubit.updateField(
                  (settings) => settings.copyWith(billerId: raw),
                );
                Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
