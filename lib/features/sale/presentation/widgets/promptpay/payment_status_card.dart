import 'package:flutter/material.dart';

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
    final hasBank = sendingBankCode != null && sendingBankCode!.isNotEmpty;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasBank
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasBank ? Icons.verified : Icons.schedule,
              color: hasBank
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
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
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
