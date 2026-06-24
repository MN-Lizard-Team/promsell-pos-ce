import 'package:flutter/material.dart';

class TimerChip extends StatelessWidget {
  const TimerChip({
    super.key,
    required this.remainingSeconds,
    required this.formattedTime,
  });

  final int remainingSeconds;
  final String formattedTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTimeout = remainingSeconds <= 0;
    final isUrgent = remainingSeconds <= 30 && remainingSeconds > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isTimeout
            ? theme.colorScheme.error
            : isUrgent
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        formattedTime,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isTimeout
              ? theme.colorScheme.onError
              : isUrgent
              ? theme.colorScheme.error
              : theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
