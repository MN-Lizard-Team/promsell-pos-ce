import 'package:flutter/material.dart';

class ProductCardShell extends StatelessWidget {
  const ProductCardShell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.isActive = true,
    this.borderRadius = 16,
    this.borderColor,
    this.elevation = 0,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets? margin;
  final bool isActive;
  final double borderRadius;
  final Color? borderColor;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sideColor =
        borderColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    final card = Material(
      color: theme.colorScheme.surfaceContainerLowest,
      elevation: elevation,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: sideColor,
          width: borderColor != null ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(borderRadius),
        child: isActive ? child : Opacity(opacity: 0.55, child: child),
      ),
    );

    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}
