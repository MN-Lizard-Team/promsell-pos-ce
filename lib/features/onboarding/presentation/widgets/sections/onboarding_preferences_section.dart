import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_segmented_control.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_selection_sheet.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class OnboardingPreferencesSection extends StatelessWidget {
  const OnboardingPreferencesSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.settings,
    this.currencyController,
    required this.dateFormat,
    this.onCurrencyChanged,
    required this.onDateFormatChanged,
  });

  final Color cardBg;
  final Color accentBrand;
  final Settings settings;
  final TextEditingController? currencyController;
  final String dateFormat;
  final ValueChanged<String>? onCurrencyChanged;
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
          OnboardingSegmentedControl<String>(
            segments: [
              ButtonSegment(
                value: 'th',
                label: Text(context.l10n.onboardingThai),
              ),
              ButtonSegment(
                value: 'en',
                label: Text(context.l10n.onboardingEnglish),
              ),
            ],
            selected: {settings.localeCode},
            onSelectionChanged: (selection) {
              context.read<SettingsCubit>().updateField(
                (_) => settings.copyWith(localeCode: selection.first),
              );
            },
          ),
          const SizedBox(height: 16),
          if (currencyController != null) ...[
            OnboardingSelectionField<String>(
              label: context.l10n.onboardingCurrency,
              valueLabel: switch (currencyController!.text) {
                '฿' => context.l10n.onboardingCurrencyBaht,
                r'$' => context.l10n.onboardingCurrencyUsd,
                '€' => context.l10n.onboardingCurrencyEur,
                '¥' => context.l10n.onboardingCurrencyJpy,
                _ => currencyController!.text,
              },
              icon: Icons.payments_outlined,
              onTap: () async {
                final selected = await OnboardingSelectionSheet.show<String>(
                  context: context,
                  title: context.l10n.onboardingCurrency,
                  selected: currencyController!.text,
                  options: [
                    OnboardingSelectionOption(
                      value: '฿',
                      label: context.l10n.onboardingCurrencyBaht,
                      icon: Icons.currency_exchange,
                    ),
                    OnboardingSelectionOption(
                      value: r'$',
                      label: context.l10n.onboardingCurrencyUsd,
                      icon: Icons.currency_exchange,
                    ),
                    OnboardingSelectionOption(
                      value: '€',
                      label: context.l10n.onboardingCurrencyEur,
                      icon: Icons.currency_exchange,
                    ),
                    OnboardingSelectionOption(
                      value: '¥',
                      label: context.l10n.onboardingCurrencyJpy,
                      icon: Icons.currency_exchange,
                    ),
                  ],
                );
                if (selected == null || !context.mounted) return;
                currencyController!.text = selected;
                onCurrencyChanged?.call(selected);
              },
            ),
            const SizedBox(height: 16),
          ],
          Text(context.l10n.settingsTheme),
          const SizedBox(height: 8),
          OnboardingSegmentedControl<String>(
            segments: [
              ButtonSegment(
                value: 'light',
                label: Text(context.l10n.settingsThemeLight),
              ),
              ButtonSegment(
                value: 'dark',
                label: Text(context.l10n.settingsThemeDark),
              ),
              ButtonSegment(
                value: 'system',
                label: Text(context.l10n.settingsThemeSystem),
              ),
            ],
            selected: {settings.themeModeName},
            onSelectionChanged: (selection) {
              context.read<SettingsCubit>().updateField(
                (_) => settings.copyWith(themeModeName: selection.first),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(context.l10n.onboardingDateFormat),
          const SizedBox(height: 8),
          OnboardingSelectionField<String>(
            label: context.l10n.onboardingDateFormat,
            valueLabel: dateFormat,
            icon: Icons.calendar_today_outlined,
            onTap: () async {
              final selected = await OnboardingSelectionSheet.show<String>(
                context: context,
                title: context.l10n.onboardingDateFormat,
                selected: dateFormat,
                options: [
                  const OnboardingSelectionOption(
                    value: 'dd/MM/yyyy',
                    label: 'dd/MM/yyyy',
                    subtitle: '20/01/2026',
                    icon: Icons.calendar_today_outlined,
                  ),
                  const OnboardingSelectionOption(
                    value: 'MM/dd/yyyy',
                    label: 'MM/dd/yyyy',
                    subtitle: '01/20/2026',
                    icon: Icons.calendar_today_outlined,
                  ),
                  const OnboardingSelectionOption(
                    value: 'yyyy-MM-dd',
                    label: 'yyyy-MM-dd',
                    subtitle: '2026-01-20',
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              );
              if (selected != null && context.mounted) {
                onDateFormatChanged(selected);
              }
            },
          ),
        ],
      ),
    );
  }
}
