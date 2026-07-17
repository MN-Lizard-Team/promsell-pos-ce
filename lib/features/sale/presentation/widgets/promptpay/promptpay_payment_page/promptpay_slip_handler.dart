import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/slip_verifier.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
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
      final bankSuffix = result.bankNameTh != null
          ? ' — ${result.bankNameTh}'
          : '';
      AppSnackBar.success(
        context,
        '${context.l10n.slipScanSuccess}$bankSuffix',
      );
      if (settings.autoConfirmAfterSlip) {
        onValidSlip();
      }
    } else {
      final errorText = switch (result.errorType) {
        SlipErrorType.emptyPayload => context.l10n.slipErrorEmpty,
        SlipErrorType.notASlipQr => context.l10n.slipErrorNotASlip,
        SlipErrorType.unreadable => context.l10n.slipErrorUnreadable,
        null => result.errorMessage ?? context.l10n.promptpayInvalidQr,
      };
      AppSnackBar.error(context, errorText);
    }
  }

  static Timer? scheduleAutoConfirm(
    BuildContext context,
    VoidCallback onConfirm,
  ) {
    const delay = Duration(seconds: 2);
    final l10n = context.l10n;

    Timer? timer;
    timer = Timer(delay, () {
      onConfirm();
    });

    AppSnackBar.withAction(
      context,
      l10n.autoConfirmingIn(delay.inSeconds),
      actionLabel: l10n.cancel,
      onAction: () {
        timer?.cancel();
      },
      duration: delay + const Duration(milliseconds: 500),
    );
    return timer;
  }
}
