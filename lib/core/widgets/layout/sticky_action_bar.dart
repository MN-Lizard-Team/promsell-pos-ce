import 'package:flutter/material.dart';

class StickyActionBar extends StatelessWidget {
  const StickyActionBar({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.dangerLabel,
    this.onDanger,
    this.isLoading = false,
    this.sideBySide = false,
    this.primaryColor,
    this.primaryKey,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? dangerLabel;
  final VoidCallback? onDanger;
  final bool isLoading;

  /// When true, secondary + primary sit on one row (mockup-style cancel/save).
  final bool sideBySide;

  /// Optional fill color for the primary button (e.g. accent orange).
  final Color? primaryColor;

  final Key? primaryKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryStyle = primaryColor == null
        ? null
        : FilledButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          );

    Widget primaryButton() {
      return FilledButton(
        key: primaryKey,
        style: primaryStyle,
        onPressed: isLoading ? null : onPrimary,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(primaryLabel),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: sideBySide
            ? Row(
                children: [
                  if (secondaryLabel != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : onSecondary,
                        child: Text(secondaryLabel!),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: primaryButton()),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (dangerLabel != null || secondaryLabel != null)
                    Row(
                      children: [
                        if (dangerLabel != null)
                          TextButton.icon(
                            onPressed: onDanger,
                            icon: const Icon(Icons.delete_outline),
                            label: Text(dangerLabel!),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                            ),
                          ),
                        const Spacer(),
                        if (secondaryLabel != null)
                          TextButton(
                            onPressed: onSecondary,
                            child: Text(secondaryLabel!),
                          ),
                      ],
                    ),
                  primaryButton(),
                ],
              ),
      ),
    );
  }
}
