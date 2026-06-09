import 'package:thai_promptpay/thai_promptpay.dart' as pp;

/// Result of decoding a customer's PromptPay QR.
class CustomerQrDecodeResult {
  const CustomerQrDecodeResult({
    required this.isValid,
    this.targetType,
    this.targetValue,
    this.amountSatang,
    this.isDynamic,
    this.errorMessage,
  });

  final bool isValid;
  final pp.PromptPayType? targetType;
  final String? targetValue;
  final int? amountSatang;
  final bool? isDynamic;
  final String? errorMessage;

  double? get amountBaht => amountSatang == null ? null : amountSatang! / 100.0;

  @override
  String toString() =>
      'CustomerQrDecodeResult(isValid: $isValid, target: $targetValue, '
      'amountSatang: $amountSatang)';
}

/// Decodes a customer's PromptPay QR payload.
///
/// Returns structured data including recipient, amount, and QR type.
/// Never throws — returns invalid result on error.
CustomerQrDecodeResult decodeCustomerQr(String payload) {
  final decoded = pp.tryDecodePromptPay(payload);
  if (decoded == null) {
    return const CustomerQrDecodeResult(
      isValid: false,
      errorMessage: 'Invalid PromptPay QR code',
    );
  }

  return CustomerQrDecodeResult(
    isValid: true,
    targetType: decoded.target.type,
    targetValue: decoded.target.value,
    amountSatang: decoded.amountSatang,
    isDynamic: decoded.isDynamic,
  );
}
