import 'package:flutter/material.dart';

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
                        alpha: i < currentStep * 2 ? 0.6 : 0.2,
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
                  width: isActive ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive || isCompleted
                        ? accentBrand
                        : accentBrand.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
            if (stepLabel.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                stepLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accentBrand,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
