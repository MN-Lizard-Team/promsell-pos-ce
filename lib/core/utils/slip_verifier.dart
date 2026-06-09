import 'package:thai_promptpay/thai_promptpay.dart' as pp;

/// Categories of scan failures for user-friendly messaging.
enum SlipErrorType { emptyPayload, notASlipQr, unreadable }

/// Result of decoding a slip-verify Mini-QR from a Thai bank transfer slip.
class SlipVerifyResult {
  const SlipVerifyResult({
    required this.isValid,
    this.transRef,
    this.sendingBankCode,
    this.bankNameTh,
    this.bankNameEn,
    this.errorMessage,
    this.errorType,
  });

  final bool isValid;
  final String? transRef;
  final String? sendingBankCode;
  final String? bankNameTh;
  final String? bankNameEn;
  final String? errorMessage;
  final SlipErrorType? errorType;

  @override
  String toString() =>
      'SlipVerifyResult(isValid: $isValid, transRef: $transRef, '
      'bank: $bankNameTh)';
}

/// Decodes a Slip Verify Mini-QR payload into structured data.
///
/// Returns a [SlipVerifyResult] with transaction reference, bank details,
/// and validation status. Never throws — returns invalid result on error.
SlipVerifyResult verifySlip(String payload) {
  final trimmed = payload.trim();

  if (trimmed.isEmpty) {
    return const SlipVerifyResult(
      isValid: false,
      errorType: SlipErrorType.emptyPayload,
      errorMessage: 'Empty QR code detected',
    );
  }

  // Heuristic: PromptPay payment QR starts with "0002" or "000201"
  // Slip QR is usually shorter and uses a different format.
  // tryDecodeSlip handles the real check; this is just for better errors.
  final slip = pp.tryDecodeSlip(trimmed);
  if (slip == null) {
    // Try to detect if it's a regular PromptPay payment QR
    if (trimmed.startsWith('000201') || trimmed.startsWith('0002')) {
      return const SlipVerifyResult(
        isValid: false,
        errorType: SlipErrorType.notASlipQr,
        errorMessage:
            'This is a payment QR, not a bank slip. Please scan the QR on the bank transfer slip.',
      );
    }
    return const SlipVerifyResult(
      isValid: false,
      errorType: SlipErrorType.unreadable,
      errorMessage: 'Unable to read slip QR. Please try again.',
    );
  }

  switch (slip) {
    case pp.BankSlip s:
      final bank = s.bank;
      return SlipVerifyResult(
        isValid: true,
        transRef: s.transRef,
        sendingBankCode: s.sendingBankCode,
        bankNameTh: bank?.nameTh.isNotEmpty == true ? bank?.nameTh : null,
        bankNameEn: bank?.nameEn,
      );
    case pp.TrueMoneySlip s:
      return SlipVerifyResult(
        isValid: true,
        transRef: s.transactionId,
        bankNameTh: 'TrueMoney',
        bankNameEn: 'TrueMoney',
      );
  }
}
