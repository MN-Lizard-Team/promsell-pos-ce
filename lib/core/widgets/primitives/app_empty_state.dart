import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.hasBoundedHeight && constraints.maxHeight < 160;
        final veryCompact =
            constraints.hasBoundedHeight && constraints.maxHeight < 120;
        final padding = veryCompact
            ? 8.0
            : compact
            ? 12.0
            : 24.0;
        final iconSize = veryCompact
            ? 24.0
            : compact
            ? 32.0
            : 44.0;
        final gap = veryCompact
            ? 6.0
            : compact
            ? 8.0
            : 12.0;
        final titleStyle = veryCompact
            ? theme.textTheme.bodyMedium
            : theme.textTheme.titleMedium;

        return Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize, color: theme.colorScheme.secondary),
                SizedBox(height: gap),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: veryCompact
                      ? 1
                      : compact
                      ? 2
                      : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: titleStyle,
                ),
                if (message != null && !compact) ...[
                  const SizedBox(height: 6),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
                if (actionLabel != null && onAction != null && !compact) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
