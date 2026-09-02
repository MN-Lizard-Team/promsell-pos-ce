import 'package:flutter/material.dart';

/// Shared section shell for onboarding steps. Mirrors the Settings Command
/// Dashboard visual language: left accent stripe, tinted icon well, bold
/// title (w800), optional subtitle, and consistent 16px padding.
class OnboardingSection extends StatelessWidget {
  const OnboardingSection({
    super.key,
    required this.cardBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final Color cardBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = iconColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(icon, color: accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  child,
                ],
              ),
            ),
          ),
          // Left accent stripe.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
