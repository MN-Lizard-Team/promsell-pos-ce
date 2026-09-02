import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Bottom navigation bar for onboarding. Single primary CTA (Next / Start
/// Selling) with a back chevron on the left and a subtle Skip link above.
/// The last step uses accent orange to signal the finish action.
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    required this.isLastStep,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final bool isLastStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canGoBack = currentStep > 0;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skip link row (subtle, right-aligned).
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(context.l10n.onboardingSkipSetup),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Primary CTA row: back chevron + full-width Next/Start.
            Row(
              children: [
                if (canGoBack)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton.filledTonal(
                      onPressed: onBack,
                      tooltip: context.l10n.onboardingBack,
                      icon: const Icon(TablerIcons.chevronLeft, size: 22),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                  ),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: isLastStep
                          ? AppColors.accent
                          : theme.colorScheme.primary,
                      // White on accent orange is ~2.85:1 — below WCAG AA
                      // even for large text. Dark ink passes (~6.2:1).
                      foregroundColor: isLastStep
                          ? AppColors.textPrimary
                          : theme.colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      isLastStep
                          ? TablerIcons.rocket
                          : TablerIcons.chevronRight,
                      size: 20,
                    ),
                    label: Text(
                      isLastStep
                          ? context.l10n.onboardingStartSelling
                          : context.l10n.onboardingNext,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
