import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartQtyButton extends StatefulWidget {
  const CartQtyButton({super.key, required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<CartQtyButton> createState() => _CartQtyButtonState();
}

class _CartQtyButtonState extends State<CartQtyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _pressed
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(widget.icon, size: 18, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
