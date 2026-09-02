import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class OnboardingSheetOption extends StatelessWidget {
  const OnboardingSheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.black.withValues(alpha: 0.85);
    return Semantics(
      button: true,
      selected: selected,
      label: subtitle == null ? label : '$label, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? accentColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              border: Border.all(
                color: selected
                    ? accentColor
                    : theme.colorScheme.outlineVariant,
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: selected ? accentColor : textColor,
                ),
                const SizedBox(width: 12),
                Icon(icon, size: 20, color: selected ? accentColor : textColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? accentColor : textColor,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: selected
                                ? accentColor
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Icon(TablerIcons.check, size: 20, color: accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
