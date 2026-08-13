import 'package:flutter/material.dart';

/// Animated quantity badge with bounce effect on item count change.
class CartBounceBadge extends StatefulWidget {
  const CartBounceBadge({
    super.key,
    required this.count,
    required this.bounce,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final int count;
  final bool bounce;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  State<CartBounceBadge> createState() => _CartBounceBadgeState();
}

class _CartBounceBadgeState extends State<CartBounceBadge> {
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: widget.bounce ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          '${widget.count}',
          key: ValueKey(widget.count),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: widget.foregroundColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
