import 'package:flutter/material.dart';

class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    super.key,
    required this.progress,
    required this.accentBrand,
  });

  final double progress;
  final Color accentBrand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: accentBrand.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(accentBrand),
              minHeight: 6,
            );
          },
        ),
      ),
    );
  }
}
