import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

class TimerProgressBar extends StatelessWidget {
  const TimerProgressBar({
    super.key,
    required this.remainingSeconds,
    required this.maxSeconds,
    required this.lastProgress,
  });

  final int remainingSeconds;
  final int maxSeconds;
  final double lastProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (remainingSeconds / maxSeconds).clamp(0.0, 1.0);
    final isUrgent = remainingSeconds <= 30;
    Color barColor;
    if (progress > 0.5) {
      barColor = theme.colorScheme.primary;
    } else if (progress > 0.2) {
      barColor = AppColors.warning;
    } else {
      barColor = theme.colorScheme.error;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: lastProgress, end: progress),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
          minHeight: isUrgent ? 6 : 4,
        );
      },
    );
  }
}
