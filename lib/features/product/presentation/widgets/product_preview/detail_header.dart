import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.title,
    required this.isActive,
    required this.onBack,
    this.subtitle,
    this.onToggleActive,
    this.onMenu,
  });

  static const double bottomPadding = 64;
  static const double cardOverlapOffset = 8;

  final String title;
  final String? subtitle;
  final bool isActive;
  final VoidCallback onBack;

  /// When null, the visibility toggle is hidden (e.g. product form).
  final VoidCallback? onToggleActive;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onPrimary = cs.onPrimary;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.viewPaddingOf(context).top + 8,
        left: 12,
        right: 8,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: Icon(Icons.arrow_back, color: onPrimary),
            onPressed: onBack,
          ),
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: onPrimary.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (onToggleActive != null)
            IconButton(
              tooltip: isActive
                  ? context.l10n.deactivate
                  : context.l10n.activate,
              icon: Icon(
                isActive
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: onPrimary,
              ),
              onPressed: onToggleActive,
            ),
          if (onMenu != null)
            IconButton(
              tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
              icon: Icon(Icons.more_vert, color: onPrimary),
              onPressed: onMenu,
            ),
        ],
      ),
    );
  }
}
