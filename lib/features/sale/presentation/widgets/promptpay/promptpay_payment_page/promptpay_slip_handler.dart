import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/slip_verifier.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/slip_scanner_dialog.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class PromptPaySlipHandler {
  PromptPaySlipHandler._();

  static Future<void> scanSlip(
    BuildContext context, {
    required Settings settings,
    required TextEditingController referenceCtrl,
    required ValueChanged<String?> onBankCodeChanged,
    required VoidCallback onValidSlip,
  }) async {
    HapticFeedback.lightImpact();
    final result = await Navigator.of(context).push<SlipVerifyResult>(
      MaterialPageRoute(builder: (_) => const SlipScannerDialog()),
    );
    if (result == null || !context.mounted) return;

    if (result.isValid) {
      onBankCodeChanged(result.sendingBankCode);
      referenceCtrl.text = result.transRef ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.verified,
                color: AppColors.overlayIcon,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${context.l10n.slipScanSuccess}${result.bankNameTh != null ? ' — ${result.bankNameTh}' : ''}',
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      if (settings.autoConfirmAfterSlip) {
        onValidSlip();
      }
    } else {
      final theme = Theme.of(context);
      final isWrongQr = result.errorType == SlipErrorType.notASlipQr;
      final errorText = switch (result.errorType) {
        SlipErrorType.emptyPayload => context.l10n.slipErrorEmpty,
        SlipErrorType.notASlipQr => context.l10n.slipErrorNotASlip,
        SlipErrorType.unreadable => context.l10n.slipErrorUnreadable,
        null => result.errorMessage ?? context.l10n.promptpayInvalidQr,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isWrongQr ? Icons.qr_code_scanner : Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(errorText)),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: theme.colorScheme.errorContainer,
        ),
      );
    }
  }

  static Timer? scheduleAutoConfirm(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    const delay = Duration(seconds: 2);
    final end = DateTime.now().add(delay);
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: StreamBuilder<int>(
          stream: Stream.periodic(const Duration(milliseconds: 100), (_) {
            final remaining = end.difference(DateTime.now()).inMilliseconds;
            return (remaining / 1000).ceil().clamp(0, 2);
          }),
          builder: (context, snapshot) {
            final secs = snapshot.data ?? 2;
            return Text(l10n.autoConfirmingIn(secs));
          },
        ),
        duration: delay + const Duration(milliseconds: 500),
        action: SnackBarAction(label: l10n.cancel, onPressed: () {}),
      ),
    );
    return Timer(delay, onConfirm);
  }
}
