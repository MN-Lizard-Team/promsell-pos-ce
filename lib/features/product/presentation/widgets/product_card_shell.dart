import 'package:flutter/material.dart';

class ProductCardShell extends StatelessWidget {
  const ProductCardShell({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.isActive = true,
    this.borderRadius = 20,
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

    Widget content = Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: margin ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: theme.colorScheme.surfaceContainerLowest,
      child: InkWell(onTap: onTap, onLongPress: onLongPress, child: child),
    );

    if (!isActive) {
      content = Opacity(opacity: 0.55, child: content);
    }

    return content;
  }
}
