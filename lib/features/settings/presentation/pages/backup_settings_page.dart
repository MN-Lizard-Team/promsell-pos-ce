import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';

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
              _BackupStatusCard(
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
              _BackupInfoCard(st: st, l10n: l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    AppSettings s,
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
            onTap: () => _showReminderDialog(context, s, cubit, st, l10n),
          ),
      ],
    );
  }

  void _showReminderDialog(
    BuildContext context,
    AppSettings s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final ctrl = TextEditingController(text: s.backupReminderDays.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupFrequency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    (7, l10n.backupWeekly),
                    (14, l10n.backupBiweekly),
                    (30, l10n.backupMonthly),
                    (60, l10n.backupBimonthly),
                    (90, l10n.backupQuarterly),
                  ].map((preset) {
                    final (value, label) = preset;
                    return ChoiceChip(
                      label: Text('$label ($value)'),
                      selected: false,
                      onSelected: (_) {
                        ctrl.text = '$value';
                      },
                      selectedColor: st.softAccentContainer,
                      backgroundColor: st.cardBackground,
                      side: BorderSide(color: st.cardBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n != null && n >= 0) {
                cubit.updateField((s) => s.copyWith(backupReminderDays: n));
              }
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _BackupStatusCard extends StatelessWidget {
  const _BackupStatusCard({
    required this.lastBackupAt,
    required this.reminderDays,
    required this.st,
    required this.l10n,
  });

  final String? lastBackupAt;
  final int reminderDays;
  final SettingsThemeExtension st;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel, statusIcon) = _statusInfo();
    final lastBackupText = _lastBackupText();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.25),
            statusColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(statusIcon, color: statusColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            statusLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, color: st.softTextSecondary, size: 16),
              const SizedBox(width: 6),
              Text(
                '${l10n.backupLastBackup}: $lastBackupText',
                style: TextStyle(fontSize: 14, color: st.softTextSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  (Color, String, IconData) _statusInfo() {
    if (lastBackupAt == null || lastBackupAt!.isEmpty) {
      return (
        AppColors.warning,
        l10n.backupStatusOverdue,
        Icons.warning_amber_outlined,
      );
    }
    final last = DateTime.tryParse(lastBackupAt!);
    if (last == null) {
      return (
        AppColors.warning,
        l10n.backupStatusOverdue,
        Icons.warning_amber_outlined,
      );
    }
    final daysSince = DateTime.now().difference(last).inDays;
    if (reminderDays <= 0) {
      return (AppColors.info, l10n.backupStatusSafe, Icons.shield_outlined);
    }
    if (daysSince > reminderDays) {
      return (AppColors.error, l10n.backupStatusOverdue, Icons.error_outline);
    }
    if (daysSince > (reminderDays * 0.75).floor()) {
      return (
        AppColors.warning,
        l10n.backupStatusWarning,
        Icons.watch_later_outlined,
      );
    }
    return (
      AppColors.success,
      l10n.backupStatusSafe,
      Icons.check_circle_outline,
    );
  }

  String _lastBackupText() {
    if (lastBackupAt == null || lastBackupAt!.isEmpty) {
      return '-';
    }
    final last = DateTime.tryParse(lastBackupAt!);
    if (last == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(last).inDays;
    if (diff == 0) return l10n.backupToday;
    if (diff == 1) return l10n.backupYesterday;
    return l10n.backupDaysAgo(diff);
  }
}

class _BackupInfoCard extends StatelessWidget {
  const _BackupInfoCard({required this.st, required this.l10n});

  final SettingsThemeExtension st;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: st.iconContainerBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: st.softAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.backupInfoDescription,
              style: TextStyle(
                fontSize: 13,
                color: st.softTextSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
