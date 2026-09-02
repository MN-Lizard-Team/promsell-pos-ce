import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Action card for the Settings root grid: left accent stripe, tinted icon
/// well, title, optional subtitle, optional status badge, and a trailing
/// chevron so the destination affordance is explicit. Cards enforce the
/// theme's [SettingsThemeExtension.actionCardMinHeight] so wide-grid rows
/// keep equal heights. [emphasized] renders a stronger icon well for
/// readiness-critical tiles (shop info, PromptPay, backup).
class SettingsActionCard extends StatelessWidget {
  const SettingsActionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.accentColor,
    this.statusBadge,
    this.emphasized = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accentColor;
  final Widget? statusBadge;
  final bool emphasized;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final accent = accentColor ?? st.softAccent;

    return Semantics(
      button: onTap != null,
      label: title,
      hint: subtitle,
      child: Material(
        color: st.cardBackground,
        clipBehavior: Clip.antiAlias,
        // POS paper-card language: hairline outlineVariant border + faint
        // elevation (ProductCardShell / RichProductListTile). Emphasized
        // tiles reuse the selected-product teal border instead of a stripe.
        elevation: 0.5,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(st.actionCardRadius),
          side: emphasized
              ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
              : BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: accent.withValues(alpha: 0.10),
          highlightColor: accent.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: st.actionCardMinHeight),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: accent.withValues(
                              alpha: emphasized ? 0.14 : 0.10,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: accent, size: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: st.softTextSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      ?statusBadge,
                      // No badge: optically center the chevron against the
                      // 32 dp icon well ((32 - 18) / 2). With a badge the
                      // chevron tucks right under it.
                      SizedBox(height: statusBadge == null ? 7 : 4),
                      Icon(
                        TablerIcons.chevronRight,
                        size: 18,
                        color: st.softTextSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
