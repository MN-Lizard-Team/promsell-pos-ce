import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

enum CloseDayCtaStyle {
  /// Full-width tonal button (Report overview).
  button,

  /// Extended FAB (History list overlay).
  fab,
}

/// Unified close-day action chrome for Report overview + History.
class CloseDayCta extends StatelessWidget {
  const CloseDayCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = CloseDayCtaStyle.button,
    this.heroTag = 'close_day_cta',
  });

  final String label;
  final VoidCallback onPressed;
  final CloseDayCtaStyle style;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final reportTheme =
        Theme.of(context).extension<ReportThemeExtension>() ??
        ReportThemeExtension.light;
    final icon = const Icon(TablerIcons.circleCheck, size: 18);

    if (style == CloseDayCtaStyle.fab) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        heroTag: heroTag,
        icon: icon,
        label: Text(label),
      );
    }

    return Semantics(
      button: true,
      label: label,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(reportTheme.cardRadius),
          ),
        ),
      ),
    );
  }
}
