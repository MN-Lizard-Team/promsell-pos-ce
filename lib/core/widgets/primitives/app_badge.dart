import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

enum BadgeType { success, info, warning, error }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
    this.fontSize = 12,
  });

  final String label;
  final BadgeType type;
  final IconData? icon;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: colors.$2),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: colors.$2,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _colorsFor(BadgeType type) {
    return switch (type) {
      BadgeType.success => (AppColors.successContainer, AppColors.success),
      BadgeType.info => (AppColors.infoContainer, AppColors.info),
      BadgeType.warning => (AppColors.accentContainer, AppColors.warning),
      BadgeType.error => (AppColors.errorContainer, AppColors.error),
    };
  }
}
