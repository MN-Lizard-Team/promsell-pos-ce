import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page/backup_reminder_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/backup/backup_info_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/backup/backup_status_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';

class BackupSettingsPage extends StatelessWidget {
  const BackupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final st = context.settingsTheme;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsBackup)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              BackupStatusCard(
                lastBackupAt: s.lastBackupAt,
                reminderDays: s.backupReminderDays,
                st: st,
                l10n: l10n,
              ),
              const SizedBox(height: 24),
              _buildReminderTile(context, s, cubit, st, l10n),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.backupEncryptionTitle,
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    secondary: Container(
                      width: st.iconSize,
                      height: st.iconSize,
                      decoration: BoxDecoration(
                        color: st.iconContainerBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.enhanced_encryption_outlined,
                        color: st.softAccent,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      l10n.backupEncryptionLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      l10n.backupEncryptionDesc,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: st.mutedText,
                        fontSize: 14,
                      ),
                    ),
                    value: s.backupEncryptionEnabled,
                    activeTrackColor: st.softAccent,
                    onChanged: (v) {
                      cubit.updateField(
                        (settings) =>
                            settings.copyWith(backupEncryptionEnabled: v),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.backupActionTitle,
                children: [
                  ListTile(
                    minTileHeight: st.tileMinHeight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: st.iconSize,
                      height: st.iconSize,
                      decoration: BoxDecoration(
                        color: st.iconContainerBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.backup_outlined,
                        color: st.softAccent,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      l10n.backupNow,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      l10n.backupActionSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: st.mutedText,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: st.softTextSecondary,
                      size: 24,
                    ),
                    onTap: () {
                      final now = DateTime.now().toIso8601String();
                      cubit.updateField((s) => s.copyWith(lastBackupAt: now));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.backupSuccess)),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BackupInfoCard(st: st, l10n: l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final enabled = s.backupReminderDays > 0;

    return SettingsSectionCard(
      title: l10n.backupReminderLabel,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            l10n.backupReminderLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            enabled
                ? l10n.backupEveryNDays(s.backupReminderDays)
                : l10n.backupOff,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled ? st.softAccent : st.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          value: enabled,
          activeTrackColor: st.softAccent,
          onChanged: (v) {
            if (v) {
              cubit.updateField(
                (settings) => settings.copyWith(backupReminderDays: 7),
              );
            } else {
              cubit.updateField(
                (settings) => settings.copyWith(backupReminderDays: 0),
              );
            }
          },
        ),
        if (enabled)
          ListTile(
            minTileHeight: st.tileMinHeight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: const SizedBox(width: 48),
            title: Text(
              l10n.backupFrequency,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              l10n.backupEveryNDays(s.backupReminderDays),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: st.softAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: st.softTextSecondary,
              size: 24,
            ),
            onTap: () => BackupReminderDialog.show(context, s, cubit, st, l10n),
          ),
      ],
    );
  }
}
