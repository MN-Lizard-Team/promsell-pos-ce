import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          SettingsSectionCard(
            title: l10n.dataCollection,
            children: [
              _PolicyBody(text: l10n.dataCollectionBody, st: st, theme: theme),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.thirdPartyServices,
            children: [
              _PolicyBody(
                text: l10n.thirdPartyServicesBody,
                st: st,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.dataStorage,
            children: [
              _PolicyBody(text: l10n.dataStorageBody, st: st, theme: theme),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.backupEncryptionTitle,
            children: [
              _PolicyBody(
                text: l10n.backupEncryptionBody,
                st: st,
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.permissionsTitle,
            children: [
              _PolicyBody(text: l10n.permissionsCamera, st: st, theme: theme),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _PolicyBody(text: l10n.permissionsStorage, st: st, theme: theme),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _PolicyBody(text: l10n.permissionsInternet, st: st, theme: theme),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.crashLoggingTitle,
            children: [
              _PolicyBody(text: l10n.crashLoggingBody, st: st, theme: theme),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.contactTitle,
            children: [
              _PolicyBody(text: l10n.contactBody, st: st, theme: theme),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PolicyBody extends StatelessWidget {
  const _PolicyBody({
    required this.text,
    required this.st,
    required this.theme,
  });

  final String text;
  final SettingsThemeExtension st;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: st.softTextPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}
