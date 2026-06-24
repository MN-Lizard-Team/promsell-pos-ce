import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/brand_choice_chip.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class OnboardingPreferencesSection extends StatelessWidget {
  const OnboardingPreferencesSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.settings,
    required this.dateFormat,
    required this.onDateFormatChanged,
  });

  final Color cardBg;
  final Color accentBrand;
  final Settings settings;
  final String dateFormat;
  final ValueChanged<String> onDateFormatChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingSection(
      cardBg: cardBg,
      icon: Icons.settings,
      iconColor: accentBrand,
      title: context.l10n.onboardingLocaleCurrencyTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.onboardingLanguage),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              BrandChoiceChip(
                label: Text(context.l10n.onboardingThai),
                selected: settings.locale.languageCode == 'th',
                onSelected: (_) => context.read<SettingsCubit>().updateField(
                  (_) => settings.copyWith(locale: const Locale('th')),
                ),
              ),
              BrandChoiceChip(
                label: Text(context.l10n.onboardingEnglish),
                selected: settings.locale.languageCode == 'en',
                onSelected: (_) => context.read<SettingsCubit>().updateField(
                  (_) => settings.copyWith(locale: const Locale('en')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(context.l10n.settingsTheme),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              BrandChoiceChip(
                label: Text(context.l10n.settingsThemeLight),
                selected: settings.themeMode == ThemeMode.light,
                onSelected: (_) => context.read<SettingsCubit>().updateField(
                  (_) => settings.copyWith(themeMode: ThemeMode.light),
                ),
              ),
              BrandChoiceChip(
                label: Text(context.l10n.settingsThemeDark),
                selected: settings.themeMode == ThemeMode.dark,
                onSelected: (_) => context.read<SettingsCubit>().updateField(
                  (_) => settings.copyWith(themeMode: ThemeMode.dark),
                ),
              ),
              BrandChoiceChip(
                label: Text(context.l10n.settingsThemeSystem),
                selected: settings.themeMode == ThemeMode.system,
                onSelected: (_) => context.read<SettingsCubit>().updateField(
                  (_) => settings.copyWith(themeMode: ThemeMode.system),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(context.l10n.onboardingDateFormat),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: dateFormat,
            items: const [
              DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
              DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
              DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
            ],
            onChanged: (v) => onDateFormatChanged(v!),
          ),
        ],
      ),
    );
  }
}
