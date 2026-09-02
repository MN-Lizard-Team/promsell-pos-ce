import 'package:flutter/material.dart';

/// Section header for Settings sub-pages and the root dashboard. POS-native:
/// a plain bold label on the slate canvas (same rhythm as the sale catalog's
/// "Categories" label) instead of a tinted pill.
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader(
    this.title, {
    this.accent,
    this.showDot = true,
    super.key,
  });

  final String title;

  /// Retained for API compatibility with sub-pages; the plain-label style
  /// no longer tints the header.
  final Color? accent;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
