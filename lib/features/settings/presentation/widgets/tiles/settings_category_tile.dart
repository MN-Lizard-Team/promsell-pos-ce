import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SettingsCategoryTile extends StatelessWidget {
  const SettingsCategoryTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.accentColor,
    this.valuePreview,
    this.statusChip,
    this.hasUnsavedChanges = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accentColor;
  final Widget? valuePreview;
  final Widget? statusChip;
  final bool hasUnsavedChanges;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final accent = accentColor ?? st.softAccent;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
        child: Container(
          constraints: BoxConstraints(minHeight: st.tileMinHeight),
          padding: st.tilePadding,
          child: Row(
            children: [
              Container(
                width: st.iconSize,
                height: st.iconSize,
                decoration: BoxDecoration(
                  color: st.iconContainerBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: st.softTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (valuePreview != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: valuePreview!,
                      ),
                  ],
                ),
              ),
              if (statusChip != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: statusChip!,
                ),
              if (hasUnsavedChanges)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: st.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              Icon(Icons.chevron_right, color: st.mutedText, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
