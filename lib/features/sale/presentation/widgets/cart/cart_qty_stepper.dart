import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CartQtyStepper extends StatelessWidget {
  const CartQtyStepper({
    super.key,
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
    required this.onQtyTap,
  });

  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onQtyTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove,
            onTap: () {
              HapticFeedback.selectionClick();
              onDecrement();
            },
          ),
          GestureDetector(
            onTap: onQtyTap,
            child: Container(
              constraints: const BoxConstraints(minWidth: 28),
              alignment: Alignment.center,
              child: Text(
                '$qty',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'NotoSansThai',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add,
            onTap: () {
              HapticFeedback.selectionClick();
              onIncrement();
            },
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatefulWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Icon(widget.icon, size: 16, color: theme.colorScheme.primary),
        ),
      ),
    );
  }
}
