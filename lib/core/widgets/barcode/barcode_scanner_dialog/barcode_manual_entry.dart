import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class BarcodeManualEntry extends StatelessWidget {
  const BarcodeManualEntry({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      key: const ValueKey('manual'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            autofocus: true,
            onSubmitted: (_) => onSubmit(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: l10n.enterBarcodeManually,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onSubmit,
                  child: Text(l10n.submit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
