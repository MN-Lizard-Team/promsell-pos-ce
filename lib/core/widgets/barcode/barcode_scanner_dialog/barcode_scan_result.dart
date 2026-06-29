import 'package:flutter/material.dart';

class BarcodeScanResult extends StatelessWidget {
  const BarcodeScanResult({
    super.key,
    required this.scannedValue,
    required this.successLabel,
    this.productName,
    this.productPrice,
    this.isFound,
    this.notFoundLabel,
  });

  final String? scannedValue;
  final String successLabel;
  final String? productName;
  final double? productPrice;
  final bool? isFound;
  final String? notFoundLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isFound == false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cancel, color: theme.colorScheme.error, size: 48),
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
            notFoundLabel ?? 'Product not found',
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 13,
              shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 48),
        const SizedBox(height: 8),
        if (productName != null) ...[
          Text(
            productName!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 6, color: Colors.black)],
            ),
          ),
          if (productPrice != null) ...[
            const SizedBox(height: 4),
            Text(
              productPrice!.toStringAsFixed(2),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
              ),
            ),
          ],
        ] else ...[
          Text(
            scannedValue ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 6, color: Colors.black)],
            ),
          ),
        ],
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
