import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockStepper extends StatelessWidget {
  const StockStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.onQtyTap,
    this.min = 0,
    this.max = 9999,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final VoidCallback? onQtyTap;
  final int min;
  final int max;

  void _increment() {
    HapticFeedback.lightImpact();
    if (value < max) onChanged(value + 1);
  }

  void _decrement() {
    HapticFeedback.lightImpact();
    if (value > min) onChanged(value - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canDec = value > min;
    final canInc = value < max;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onPressed: canDec ? _decrement : null,
          ),
          InkWell(
            onTap: onQtyTap,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _StepButton(icon: Icons.add, onPressed: canInc ? _increment : null),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
