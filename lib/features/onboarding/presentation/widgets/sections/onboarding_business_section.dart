import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/brand_choice_chip.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';

class OnboardingBusinessSection extends StatelessWidget {
  const OnboardingBusinessSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.vatMode,
    required this.vatRateController,
    required this.promptPayController,
    required this.onVatModeChanged,
  });

  final Color cardBg;
  final Color accentBrand;
  final String vatMode;
  final TextEditingController vatRateController;
  final TextEditingController promptPayController;
  final ValueChanged<String> onVatModeChanged;

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
          Wrap(
            spacing: 8,
            children: [
              BrandChoiceChip(
                label: Text(context.l10n.onboardingNone),
                selected: vatMode == 'NONE',
                onSelected: (_) => onVatModeChanged('NONE'),
              ),
              BrandChoiceChip(
                label: Text(context.l10n.onboardingInclusive),
                selected: vatMode == 'INCLUSIVE',
                onSelected: (_) => onVatModeChanged('INCLUSIVE'),
              ),
              BrandChoiceChip(
                label: Text(context.l10n.onboardingExclusive),
                selected: vatMode == 'EXCLUSIVE',
                onSelected: (_) => onVatModeChanged('EXCLUSIVE'),
              ),
            ],
          ),
          if (vatMode != 'NONE') ...[
            const SizedBox(height: 16),
            TextField(
              controller: vatRateController,
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
          const SizedBox(height: 12),
          TextField(
            controller: promptPayController,
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
