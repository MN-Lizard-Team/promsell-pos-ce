import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

/// Status chip with a leading colored dot and bolder color contrast.
/// Used on root action cards and sub-page tiles to surface
/// ready / warning / error / not-set states at a glance.
class SettingsStatusChip extends StatelessWidget {
  const SettingsStatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.st,
    this.showDot = true,
  });

  final String label;
  final Color color;
  final SettingsThemeExtension st;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(st.statusBadgeRadius),
        border: Border.all(
          color: color.withValues(alpha: st.badgeBorderAlpha),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: st.badgeDotSize,
              height: st.badgeDotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
