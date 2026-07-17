import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

/// Visual tone for shared dialog chrome (header chip + confirm CTA).
enum DialogTone {
  /// Default informational / neutral structure.
  neutral,

  /// Primary commit (save, continue) — accent orange CTA.
  primary,

  /// Remove / clear / delete — soft peach icon + accent orange CTA
  /// (matches POS confirm mockups; not Material red).
  destructive,
}

/// Shared dialog chrome aligned to POS confirm mockups:
/// centered circular icon, title, optional detail/footnote, twin pill actions.
///
/// Hosted as [AlertDialog] so [ThemeData.dialogTheme] still applies.
class AppDialogShell extends StatelessWidget {
  const AppDialogShell({
    super.key,
    required this.title,
    this.message,
    this.detail,
    this.footnote,
    this.icon,
    this.tone = DialogTone.primary,
    this.body,
    required this.actions,
  });

  final String title;

  /// Supporting body under the title (optional).
  final String? message;

  /// Emphasized line (e.g. product name).
  final String? detail;

  /// Muted meta line (e.g. quantity).
  final String? footnote;

  final IconData? icon;
  final DialogTone tone;
  final Widget? body;

  /// Exactly the action widgets to place in the twin/footer row.
  /// Typically `[cancel, confirm]` — shell lays them out equally.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final contentChildren = <Widget>[
      if (icon != null) ...[
        _DialogIconCircle(icon: icon!, tone: tone),
        const SizedBox(height: 20),
      ],
      Text(
        title,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          height: 1.3,
        ),
      ),
      if (detail != null && detail!.trim().isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          detail!,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
      if (footnote != null && footnote!.trim().isNotEmpty) ...[
        const SizedBox(height: 4),
        Text(
          footnote!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
      if (message != null && message!.trim().isNotEmpty) ...[
        const SizedBox(height: 10),
        Text(
          message!,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
      if (body != null) ...[const SizedBox(height: 12), body!],
    ];

    return AlertDialog(
      alignment: Alignment.center,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      titlePadding: EdgeInsets.zero,
      title: const SizedBox.shrink(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: contentChildren,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (actions.isNotEmpty)
          Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: actions[i]),
              ],
            ],
          ),
      ],
    );
  }
}

class _DialogIconCircle extends StatelessWidget {
  const _DialogIconCircle({required this.icon, required this.tone});

  final IconData icon;
  final DialogTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg;
    final Color fg;

    switch (tone) {
      case DialogTone.destructive:
      case DialogTone.primary:
        bg = isDark
            ? AppColors.accent.withValues(alpha: 0.18)
            : AppColors.accentContainer;
        fg = AppColors.accent;
      case DialogTone.neutral:
        bg = Theme.of(context).colorScheme.primaryContainer;
        fg = Theme.of(context).colorScheme.onPrimaryContainer;
    }

    return Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 32, color: fg),
      ),
    );
  }
}
