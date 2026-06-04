import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SettingsValuePreview extends StatelessWidget {
  const SettingsValuePreview({
    this.icon,
    required this.label,
    this.color,
    super.key,
  });

  final IconData? icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final effectiveColor = color ?? st.softAccent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 16, color: effectiveColor),
        if (icon != null) const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: effectiveColor,
          ),
        ),
      ],
    );
  }
}
