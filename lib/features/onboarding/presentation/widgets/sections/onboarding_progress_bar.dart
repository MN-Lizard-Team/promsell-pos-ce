import 'package:flutter/material.dart';

/// Pill-style step indicator for onboarding. The active step renders as a
/// wide pill with the step label inside; completed steps are solid dots;
/// upcoming steps are hollow. Matches the Command Dashboard pill aesthetic.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.accentBrand,
    this.stepLabel = '',
    this.stepOfLabel = '',
    this.horizontalPadding = 24,
    this.disableAnimations = false,
  });

  final int currentStep;
  final int totalSteps;
  final Color accentBrand;
  final String stepLabel;
  final String stepOfLabel;
  final double horizontalPadding;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      label: stepOfLabel,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(totalSteps * 2 - 1, (i) {
                if (i.isOdd) {
                  return Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: accentBrand.withValues(
                        alpha: i < currentStep * 2 ? 0.5 : 0.18,
                      ),
                    ),
                  );
                }
                final stepIndex = i ~/ 2;
                final isActive = stepIndex == currentStep;
                final isCompleted = stepIndex < currentStep;
                return AnimatedContainer(
                  duration: disableAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  width: isActive ? 32 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? accentBrand
                        : accentBrand.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
            if (stepLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accentBrand.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentBrand.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      stepLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accentBrand,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    stepOfLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
