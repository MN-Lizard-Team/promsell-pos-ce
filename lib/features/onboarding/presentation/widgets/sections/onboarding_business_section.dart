import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_radio_card.dart';

class OnboardingBusinessSection extends StatelessWidget {
  const OnboardingBusinessSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.vatMode,
    required this.vatRateController,
    required this.promptPayController,
    required this.onVatModeChanged,
    this.vatRateFocus,
    this.promptPayFocus,
  });

  final Color cardBg;
  final Color accentBrand;
  final String vatMode;
  final TextEditingController vatRateController;
  final TextEditingController promptPayController;
  final ValueChanged<String> onVatModeChanged;
  final FocusNode? vatRateFocus;
  final FocusNode? promptPayFocus;

  @override
  Widget build(BuildContext context) {
    return OnboardingSection(
      cardBg: cardBg,
      icon: Icons.receipt_long,
      iconColor: accentBrand,
      title: context.l10n.onboardingTaxSetup,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.onboardingVatMode),
          const SizedBox(height: 8),
          RadioGroup<String>(
            groupValue: vatMode,
            onChanged: (value) {
              if (value != null) onVatModeChanged(value);
            },
            child: Column(
              children: [
                OnboardingRadioCard(
                  value: 'NONE',
                  groupValue: vatMode,
                  title: context.l10n.onboardingNone,
                  subtitle: context.l10n.onboardingVatNoneHelp,
                  icon: Icons.remove_circle_outline,
                  onChanged: onVatModeChanged,
                ),
                const SizedBox(height: 8),
                OnboardingRadioCard(
                  value: 'INCLUSIVE',
                  groupValue: vatMode,
                  title: context.l10n.onboardingInclusive,
                  subtitle: context.l10n.onboardingVatInclusiveHelp,
                  icon: Icons.receipt_long_outlined,
                  onChanged: onVatModeChanged,
                ),
                const SizedBox(height: 8),
                OnboardingRadioCard(
                  value: 'EXCLUSIVE',
                  groupValue: vatMode,
                  title: context.l10n.onboardingExclusive,
                  subtitle: context.l10n.onboardingVatExclusiveHelp,
                  icon: Icons.add_card_outlined,
                  onChanged: onVatModeChanged,
                ),
              ],
            ),
          ),
          if (vatMode != 'NONE') ...[
            const SizedBox(height: 16),
            TextField(
              controller: vatRateController,
              focusNode: vatRateFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => promptPayFocus?.requestFocus(),
              decoration: InputDecoration(
                labelText: context.l10n.onboardingVatRateLabel,
                suffixText: '%',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            context.l10n.onboardingPromptPayTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(context.l10n.onboardingPromptPaySubtitle),
          const SizedBox(height: 6),
          Text(
            context.l10n.onboardingPromptPaySecurity,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: promptPayController,
            focusNode: promptPayFocus,
            maxLength: 13,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: context.l10n.onboardingPromptPayIdLabel,
              hintText: context.l10n.onboardingPromptPayIdHint,
              prefixIcon: const Icon(Icons.qr_code),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
