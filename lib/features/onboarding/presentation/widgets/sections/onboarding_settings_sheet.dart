import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_sheet_option.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class OnboardingSettingsSheet {
  OnboardingSettingsSheet._();

  static void show(BuildContext context, Settings settings, Color accent) {
    final cubit = context.read<SettingsCubit>();
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language section header (pill style).
                _SheetSectionHeader(
                  icon: TablerIcons.language,
                  label: l10n.onboardingLanguage,
                  accent: accent,
                ),
                const SizedBox(height: 8),
                OnboardingSheetOption(
                  icon: TablerIcons.language,
                  label: l10n.onboardingThai,
                  selected: settings.localeCode == 'th',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(localeCode: 'th'),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: TablerIcons.language,
                  label: l10n.onboardingEnglish,
                  selected: settings.localeCode == 'en',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(localeCode: 'en'),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 12),
                // Theme section header (pill style).
                _SheetSectionHeader(
                  icon: TablerIcons.palette,
                  label: l10n.settingsTheme,
                  accent: accent,
                ),
                const SizedBox(height: 8),
                OnboardingSheetOption(
                  icon: TablerIcons.sun,
                  label: l10n.settingsThemeLight,
                  selected: settings.themeModeName == 'light',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(themeModeName: 'light'),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: TablerIcons.moon,
                  label: l10n.settingsThemeDark,
                  selected: settings.themeModeName == 'dark',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(themeModeName: 'dark'),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: TablerIcons.brightnessAuto,
                  label: l10n.settingsThemeSystem,
                  selected: settings.themeModeName == 'system',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(themeModeName: 'system'),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetSectionHeader extends StatelessWidget {
  const _SheetSectionHeader({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
