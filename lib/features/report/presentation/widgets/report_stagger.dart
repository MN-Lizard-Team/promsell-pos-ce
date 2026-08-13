import 'package:flutter/material.dart';

/// Light enter animation for Report overview sections (stagger via [index]).
/// Respects reduced-motion preferences: skips animation entirely when the
/// platform reports `disableAnimations`.
class ReportStagger extends StatelessWidget {
  const ReportStagger({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
  });

  final int index;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // Skip animation for reduced-motion users.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return child;
    }

    final delayMs = (index * 45).clamp(0, 360);
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: duration + Duration(milliseconds: delayMs),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 10),
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }
}
