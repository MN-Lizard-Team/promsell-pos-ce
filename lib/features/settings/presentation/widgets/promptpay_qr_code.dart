import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:thai_promptpay/thai_promptpay.dart' as pp;

/// Builds a PromptPay QR payload using the thai_promptpay library.
/// Supports mobile (10-digit), National ID (13-digit), and e-Wallet (15-digit).
/// Pass [amount] = null for a static QR (no amount embedded).
String buildPromptPayQrPayload({required String promptpayId, double? amount}) {
  final isMobile = promptpayId.startsWith('0') && promptpayId.length == 10;
  final isNationalId = promptpayId.length == 13;

  if (amount == null) {
    if (isMobile) {
      return pp.promptPayMobile(promptpayId);
    } else if (isNationalId) {
      return pp.promptPayNationalId(promptpayId);
    } else if (promptpayId.length == 15) {
      return pp.promptPayEWallet(promptpayId);
    } else {
      return pp.promptPayMobile(promptpayId);
    }
  }

  final satang = (amount * 100).round();
  if (isMobile) {
    return pp.promptPayMobile(promptpayId, amountSatang: satang);
  } else if (isNationalId) {
    return pp.promptPayNationalId(promptpayId, amountSatang: satang);
  } else if (promptpayId.length == 15) {
    return pp.promptPayEWallet(promptpayId, amountSatang: satang);
  } else {
    return pp.promptPayMobile(promptpayId, amountSatang: satang);
  }
}

IconData? _iconFromName(String name) {
  return switch (name) {
    'wallet' => Icons.account_balance_wallet_outlined,
    'store' => Icons.store_outlined,
    'person' => Icons.person_outline,
    'payment' => Icons.payment_outlined,
    'credit_card' => Icons.credit_card_outlined,
    'shopping_bag' => Icons.shopping_bag_outlined,
    'local_atm' => Icons.local_atm_outlined,
    'qr_code' => Icons.qr_code_outlined,
    _ => null,
  };
}

class PromptPayQrCode extends StatelessWidget {
  const PromptPayQrCode({
    super.key,
    required this.promptpayId,
    required this.amount,
    this.size = 200,
    this.overlayIcon,
  });

  final String promptpayId;
  final double amount;
  final double size;
  final String? overlayIcon;

  @override
  Widget build(BuildContext context) {
    String? payload;
    try {
      payload = buildPromptPayQrPayload(
        promptpayId: promptpayId,
        amount: amount,
      );
    } on FormatException {
      // Invalid PromptPay ID — show placeholder instead of crashing
      payload = null;
    }

    if (payload == null || payload.isEmpty) {
      return Container(
        width: size,
        height: size,
        color: Colors.white,
        child: Center(
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: size * 0.2,
          ),
        ),
      );
    }

    final iconData = overlayIcon != null ? _iconFromName(overlayIcon!) : null;
    final iconSize = size * 0.12;
    return Stack(
      alignment: Alignment.center,
      children: [
        QrImageView(
          data: payload,
          size: size,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(12),
        ),
        if (iconData != null)
          Container(
            width: iconSize,
            height: iconSize,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: Center(
              child: Icon(
                iconData,
                size: iconSize * 0.6,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}
