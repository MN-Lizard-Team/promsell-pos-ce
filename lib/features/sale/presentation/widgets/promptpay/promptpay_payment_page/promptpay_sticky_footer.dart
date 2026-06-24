import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class PromptPayStickyFooter extends StatelessWidget {
  const PromptPayStickyFooter({
    super.key,
    required this.l10n,
    required this.onCancel,
    required this.onConfirm,
  });

  final AppLocalizations l10n;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextButton(onPressed: onCancel, child: Text(l10n.cancel)),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.promptpayConfirmPayment),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
