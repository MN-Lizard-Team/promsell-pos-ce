import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
    this.accentColor,
    super.key,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final accent = accentColor ?? st.softAccent;

    return MergeSemantics(
      child: ListTile(
        minTileHeight: st.tileMinHeight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: icon != null
            ? Container(
                width: st.iconSize,
                height: st.iconSize,
                decoration: BoxDecoration(
                  color: st.iconContainerBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 24),
              )
            : null,
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: value
                      ? st.softTextSecondary
                      : st.softTextSecondary.withValues(alpha: 0.6),
                  decoration: value ? null : TextDecoration.lineThrough,
                  fontSize: 14,
                ),
              )
            : null,
        trailing: AnimatedScale(
          scale: value ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Switch(
            value: value,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(!value);
        },
      ),
    );
  }
}
