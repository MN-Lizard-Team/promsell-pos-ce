import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class PaymentInputSection extends StatelessWidget {
  const PaymentInputSection({
    super.key,
    required this.method,
    required this.referenceController,
    required this.noteController,
    required this.settings,
  });

  final String method;
  final TextEditingController referenceController;
  final TextEditingController noteController;
  final Settings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (method == 'promptpay') {
      return Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.promptpay,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.promptpayId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: referenceController,
          decoration: InputDecoration(
            labelText: context.l10n.paymentReferenceOptional,
            prefixIcon: const Icon(Icons.tag_outlined),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: noteController,
          decoration: InputDecoration(
            labelText: context.l10n.notePlaceholder,
            prefixIcon: const Icon(Icons.notes_outlined),
          ),
          textInputAction: TextInputAction.done,
          maxLines: 1,
        ),
      ],
    );
  }
}
