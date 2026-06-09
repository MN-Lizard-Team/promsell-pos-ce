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
