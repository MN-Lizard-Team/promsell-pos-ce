import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_sheet_option.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

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
      showDragHandle: false,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingLanguage,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                OnboardingSheetOption(
                  icon: Icons.language,
                  label: l10n.onboardingThai,
                  selected: settings.locale.languageCode == 'th',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(locale: const Locale('th')),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: Icons.language,
                  label: l10n.onboardingEnglish,
                  selected: settings.locale.languageCode == 'en',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(locale: const Locale('en')),
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
                const SizedBox(height: 8),
                Text(
                  l10n.settingsTheme,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                OnboardingSheetOption(
                  icon: Icons.wb_sunny,
                  label: l10n.settingsThemeLight,
                  selected: settings.themeMode == ThemeMode.light,
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(themeMode: ThemeMode.light),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: Icons.nights_stay,
                  label: l10n.settingsThemeDark,
                  selected: settings.themeMode == ThemeMode.dark,
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(themeMode: ThemeMode.dark),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: Icons.brightness_auto,
                  label: l10n.settingsThemeSystem,
                  selected: settings.themeMode == ThemeMode.system,
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => settings.copyWith(themeMode: ThemeMode.system),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
