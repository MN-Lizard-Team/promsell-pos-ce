import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
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
    final pos = context.posTheme;

    if (method == 'promptpay') {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Material(
          color: pos.billStubPaper,
          elevation: pos.elevFlat,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(pos.billStubRadius),
            side: BorderSide(color: pos.billStubBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.promptpay,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: 'NotoSansThai',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.promptpayId,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.promptpayConfirmPayment,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        TextFormField(
          controller: referenceController,
          decoration: InputDecoration(
            labelText: context.l10n.paymentReferenceOptional,
            prefixIcon: const Icon(Icons.tag_outlined),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),
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
