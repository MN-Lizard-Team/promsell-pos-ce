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
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets? margin;
  final bool isActive;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: isActive ? child : Opacity(opacity: 0.55, child: child),
        ),
      ),
    );
  }
}
