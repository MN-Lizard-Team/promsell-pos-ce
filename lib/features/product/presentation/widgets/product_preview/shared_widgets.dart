import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

const productPreviewTabPadding = EdgeInsets.fromLTRB(16, 16, 16, 96);

class PreviewCard extends StatelessWidget {
  const PreviewCard({
    super.key,
    this.icon,
    required this.title,
    required this.child,
    this.trailing,
  });

  final IconData? icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(icon: icon, title: title, trailing: trailing),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.icon,
    required this.title,
    this.trailing,
  });

  final IconData? icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ),
        ...[trailing].whereType<Widget>(),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64, maxWidth: 100),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: value),
      ],
    );
  }
}

class InfoListItem extends StatelessWidget {
  const InfoListItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
    this.trailingIcon,
    this.semanticHint,
  });

  final IconData icon;
  final String label;
  final Widget value;
  final Color? valueColor;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final row = Semantics(
      button: onTap != null,
      hint: semanticHint,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 38),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  child: Icon(icon, size: 18, color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: DefaultTextStyle.merge(
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: onTap != null
                          ? cs.primary
                          : (valueColor ?? cs.onSurface),
                    ),
                    child: value,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    trailingIcon ?? TablerIcons.chevronRight,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return onTap == null ? row : Tooltip(message: label, child: row);
  }
}

class CollapsiblePreviewCard extends StatefulWidget {
  const CollapsiblePreviewCard({
    super.key,
    this.icon,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final IconData? icon;
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<CollapsiblePreviewCard> createState() => _CollapsiblePreviewCardState();
}

class _CollapsiblePreviewCardState extends State<CollapsiblePreviewCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: cs.primary),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? TablerIcons.chevronUp
                        : TablerIcons.chevronDown,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[const SizedBox(height: 14), widget.child],
        ],
      ),
    );
  }
}
