import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class OnboardingRadioCard<T> extends StatelessWidget {
  const OnboardingRadioCard({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });

  final T value;
  final T groupValue;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = value == groupValue;

    return Semantics(
      // Single actionable node with checked state — the inner Radio widget
      // creates its own semantics node, so exclude children to stop screen
      // readers from announcing this card twice (button + radio).
      container: true,
      button: true,
      checked: selected,
      label: subtitle == null ? title : '$title, $subtitle',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? scheme.primaryContainer : scheme.surface,
                border: Border.all(
                  color: selected ? scheme.primary : scheme.outlineVariant,
                  width: selected ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Radio<T>(value: value),
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: selected
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(TablerIcons.check, color: scheme.primary, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
