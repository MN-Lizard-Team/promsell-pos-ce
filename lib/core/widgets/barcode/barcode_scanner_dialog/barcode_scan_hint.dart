import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class BarcodeScanHint extends StatelessWidget {
  const BarcodeScanHint({
    super.key,
    required this.hint,
    required this.onManualEntry,
    this.scanCount,
  });

  final String? hint;
  final VoidCallback onManualEntry;
  final int? scanCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('scanner'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.document_scanner,
          size: 32,
          color: Colors.white.withValues(alpha: 0.9),
        ),
        const SizedBox(height: 8),
        Text(
          hint ?? l10n.barcodeScannerHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 1.0),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
        const SizedBox(height: 16),
        if (scanCount != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.scanCount(scanCount!),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
              ),
            ),
          ),
        TextButton.icon(
          onPressed: onManualEntry,
          icon: const Icon(Icons.keyboard, color: Colors.white),
          label: Text(
            l10n.enterManually,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
