import 'package:flutter/material.dart';

class BarcodeScanResult extends StatelessWidget {
  const BarcodeScanResult({
    super.key,
    required this.scannedValue,
    required this.successLabel,
  });

  final String? scannedValue;
  final String successLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 48),
        const SizedBox(height: 8),
        Text(
          scannedValue ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          successLabel,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 13,
            shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
      ],
    );
  }
}
