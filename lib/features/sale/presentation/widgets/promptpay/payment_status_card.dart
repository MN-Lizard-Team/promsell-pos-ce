import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

class PaymentStatusCard extends StatelessWidget {
  const PaymentStatusCard({
    super.key,
    required this.sendingBankCode,
    required this.bankName,
    required this.verifiedLabel,
    required this.waitingLabel,
  });

  final String? sendingBankCode;
  final String? bankName;
  final String verifiedLabel;
  final String waitingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    final hasBank = sendingBankCode != null && sendingBankCode!.isNotEmpty;
    final border = hasBank ? theme.colorScheme.primary : pos.billStubBorder;
    return Material(
      elevation: pos.elevFlat,
      color: pos.billStubPaper,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pos.billStubRadius),
        side: BorderSide(color: border, width: hasBank ? 1.5 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasBank ? Icons.verified : Icons.schedule,
              color: hasBank
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasBank
                    ? '$verifiedLabel${bankName != null ? ' — $bankName' : ''}'
                    : waitingLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasBank
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
