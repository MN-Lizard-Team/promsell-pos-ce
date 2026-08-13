import 'package:equatable/equatable.dart';

class PaymentConfig extends Equatable {
  const PaymentConfig({
    this.currency = '฿',
    this.promptpayId = '',
    this.billerId = '',
    this.promptPayTimeout = 180,
    this.promptPaySoundEnabled = true,
    this.defaultQrType = 'transfer',
    this.autoConfirmAfterSlip = false,
    this.qrOverlayIcon = '',
  });

  final String currency;
  final String promptpayId;
  final String billerId;
  final int promptPayTimeout;
  final bool promptPaySoundEnabled;
  final String defaultQrType;
  final bool autoConfirmAfterSlip;
  final String qrOverlayIcon;

  bool get isPromptpayActive => promptpayId.isNotEmpty;

  /// Validates the biller ID format and checksum.
  ///
  /// PromptPay biller IDs use the Thai national ID format:
  /// - 13 digits for individuals (NISO 7064 Mod 11,10 checksum)
  /// - 15 digits for corporates (same checksum algorithm)
  ///
  /// Returns `null` when valid, or an error code string when invalid:
  /// - `BILLER_ID_EMPTY` — empty (allowed when optional)
  /// - `BILLER_ID_LENGTH` — not 13 or 15 digits
  /// - `BILLER_ID_CHECKSUM` — checksum mismatch
  String? get billerIdError {
    if (billerId.isEmpty) return null;
    final digits = billerId.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 13 && digits.length != 15) return 'BILLER_ID_LENGTH';
    if (!_verifyChecksum(digits)) return 'BILLER_ID_CHECKSUM';
    return null;
  }

  bool get isBillerIdValid => billerIdError == null;

  /// NISO 7064 Mod 11,10 checksum (used by Thai national ID and PromptPay).
  static bool _verifyChecksum(String digits) {
    if (digits.length < 2) return false;
    var sum = 0;
    for (var i = 0; i < digits.length - 1; i++) {
      sum += int.parse(digits[i]) * (digits.length - i);
    }
    final check = (11 - (sum % 11)) % 10;
    return check == int.parse(digits[digits.length - 1]);
  }

  PaymentConfig copyWith({
    String? currency,
    String? promptpayId,
    String? billerId,
    int? promptPayTimeout,
    bool? promptPaySoundEnabled,
    String? defaultQrType,
    bool? autoConfirmAfterSlip,
    String? qrOverlayIcon,
  }) {
    return PaymentConfig(
      currency: currency ?? this.currency,
      promptpayId: promptpayId ?? this.promptpayId,
      billerId: billerId ?? this.billerId,
      promptPayTimeout: promptPayTimeout ?? this.promptPayTimeout,
      promptPaySoundEnabled:
          promptPaySoundEnabled ?? this.promptPaySoundEnabled,
      defaultQrType: defaultQrType ?? this.defaultQrType,
      autoConfirmAfterSlip: autoConfirmAfterSlip ?? this.autoConfirmAfterSlip,
      qrOverlayIcon: qrOverlayIcon ?? this.qrOverlayIcon,
    );
  }

  @override
  List<Object?> get props => [
    currency,
    promptpayId,
    billerId,
    promptPayTimeout,
    promptPaySoundEnabled,
    defaultQrType,
    autoConfirmAfterSlip,
    qrOverlayIcon,
  ];
}
