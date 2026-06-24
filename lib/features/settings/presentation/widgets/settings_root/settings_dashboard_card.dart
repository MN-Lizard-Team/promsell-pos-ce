import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_dashboard_badge.dart';

class SettingsDashboardCard extends StatelessWidget {
  const SettingsDashboardCard({
    super.key,
    required this.settings,
    required this.localeLabel,
    required this.themeLabel,
    required this.themeIcon,
    required this.themeColor,
    required this.backupStatus,
    required this.st,
    this.onLocaleToggle,
    this.onThemeToggle,
  });

  final Settings settings;
  final String localeLabel;
  final String themeLabel;
  final IconData themeIcon;
  final Color themeColor;
  final ({String label, Color color}) backupStatus;
  final SettingsThemeExtension st;
  final VoidCallback? onLocaleToggle;
  final VoidCallback? onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final shopName = settings.shopName.isNotEmpty ? settings.shopName : '—';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            st.softAccent.withValues(alpha: 0.35),
            st.softAccent.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(
          color: st.softAccent.withValues(alpha: 0.50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: st.iconContainerBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.settings_outlined,
              color: st.softAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settingsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              SettingsDashboardBadge(
                icon: Icons.store_outlined,
                label: shopName,
                color: settings.shopName.isNotEmpty
                    ? st.softAccent
                    : st.mutedText,
                st: st,
              ),
              SettingsDashboardBadge(
                icon: Icons.language_outlined,
                label: localeLabel,
                color: st.softAccent,
                st: st,
                onTap: onLocaleToggle,
              ),
              SettingsDashboardBadge(
                icon: themeIcon,
                label: themeLabel,
                color: themeColor,
                st: st,
                onTap: onThemeToggle,
              ),
              SettingsDashboardBadge(
                icon: Icons.backup_outlined,
                label: backupStatus.label,
                color: backupStatus.color,
                st: st,
              ),
              SettingsDashboardBadge(
                icon: Icons.qr_code_2,
                label: settings.promptpayId.isNotEmpty
                    ? l10n.settingsStatusActive
                    : l10n.settingsStatusNotSet,
                color: settings.promptpayId.isNotEmpty
                    ? st.softAccent
                    : st.mutedText,
                st: st,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
