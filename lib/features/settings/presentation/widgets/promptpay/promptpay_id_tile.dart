import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class PromptpayIdTile extends StatelessWidget {
  const PromptpayIdTile({
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
    final hasId = settings.promptpayId.isNotEmpty;

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
          Icons.account_balance_wallet_outlined,
          color: st.softAccent,
          size: 24,
        ),
      ),
      title: Text(
        l10n.settingsPromptpayId,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        hasId ? settings.promptpayId : l10n.settingsPromptpayIdHint,
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
      onTap: () => _showIdDialog(context),
    );
  }

  void _showIdDialog(BuildContext context) {
    final ctrl = TextEditingController(text: settings.promptpayId);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsPromptpayId),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 17,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.settingsPromptpayIdHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (v) {
                try {
                  Validators.promptpayId(v);
                  return null;
                } on ArgumentError catch (e) {
                  return e.message as String?;
                }
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
                  (settings) => settings.copyWith(promptpayId: raw),
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
