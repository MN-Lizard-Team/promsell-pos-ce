import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay_info_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';

class PromptpaySettingsPage extends StatelessWidget {
  const PromptpaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final st = context.settingsTheme;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.promptpay)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              PromptpayPreviewCard(
                promptpayId: s.promptpayId,
                st: st,
                l10n: l10n,
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.promptpayAccount,
                children: [_buildIdTile(context, s, cubit, st, l10n)],
              ),
              const SizedBox(height: 24),
              PromptpayInfoCard(st: st, l10n: l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdTile(
    BuildContext context,
    dynamic s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final hasId = s.promptpayId.isNotEmpty;

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
        hasId ? s.promptpayId : l10n.settingsPromptpayIdHint,
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
      onTap: () => _showIdDialog(context, s, cubit, st, l10n),
    );
  }

  void _showIdDialog(
    BuildContext context,
    dynamic s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final ctrl = TextEditingController(text: s.promptpayId);
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
                final raw = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                if (raw.isEmpty) return null; // Allow empty to clear
                // Phone: 10 digits starting with 0
                if (raw.startsWith('0') && raw.length == 10) return null;
                // Citizen ID: 13 digits
                if (raw.length == 13) return null;
                return l10n.promptpayInvalidId;
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
