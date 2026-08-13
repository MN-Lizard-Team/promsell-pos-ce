import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class GeneralSummaryCard extends StatelessWidget {
  const GeneralSummaryCard({
    required this.locale,
    required this.themeMode,
    super.key,
  });

  final Locale locale;
  final ThemeMode themeMode;

  String _languageLabel(BuildContext context) {
    return locale.languageCode == 'th'
        ? context.l10n.langThai
        : context.l10n.langEnglish;
  }

  String _themeLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (themeMode) {
      ThemeMode.light => l10n.settingsThemeLight,
      ThemeMode.dark => l10n.settingsThemeDark,
      ThemeMode.system => l10n.settingsThemeSystem,
    };
  }

  IconData _themeIcon() {
    return switch (themeMode) {
      ThemeMode.light => TablerIcons.sun,
      ThemeMode.dark => TablerIcons.moon,
      ThemeMode.system => TablerIcons.brightnessAuto,
    };
  }

  Color _themeColor(BuildContext context) {
    return switch (themeMode) {
      ThemeMode.light => AppColors.warning,
      ThemeMode.dark => AppColors.info,
      ThemeMode.system => AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
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
            child: Icon(TablerIcons.settings, color: st.softAccent, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.settingsGeneral,
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
              _buildBadge(
                icon: TablerIcons.language,
                label: _languageLabel(context),
                color: st.softAccent,
                st: st,
              ),
              _buildBadge(
                icon: _themeIcon(),
                label: _themeLabel(context),
                color: _themeColor(context),
                st: st,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required SettingsThemeExtension st,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
