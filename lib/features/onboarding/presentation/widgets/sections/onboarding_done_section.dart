import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';

class OnboardingDoneSection extends StatelessWidget {
  const OnboardingDoneSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.onFinish,
    required this.onSkip,
  });

  final Color cardBg;
  final Color accentBrand;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return OnboardingSection(
      cardBg: cardBg,
      icon: Icons.check_circle,
      iconColor: accentBrand,
      title: context.l10n.onboardingAllSet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.onboardingReadyToSell),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onFinish,
              child: Text(context.l10n.onboardingStartSelling),
            ),
          ),
        ],
      ),
    );
  }
}
