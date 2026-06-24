import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class BackupStatusCard extends StatelessWidget {
  const BackupStatusCard({
    super.key,
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
