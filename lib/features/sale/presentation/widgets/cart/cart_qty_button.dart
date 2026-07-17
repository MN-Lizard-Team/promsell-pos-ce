import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartQtyButton extends StatelessWidget {
  const CartQtyButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      child: IconButton(
        tooltip: tooltip,
        onPressed: () {
          HapticFeedback.selectionClick();
          onPressed();
        },
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: EdgeInsets.zero,
          backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.7,
          ),
        ),
        icon: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
    );
  }
}
