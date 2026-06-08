import 'package:equatable/equatable.dart';

class PaymentConfig extends Equatable {
  const PaymentConfig({this.currency = '฿', this.promptpayId = ''});

  final String currency;
  final String promptpayId;

  bool get isPromptpayActive => promptpayId.isNotEmpty;

  PaymentConfig copyWith({String? currency, String? promptpayId}) {
    return PaymentConfig(
      currency: currency ?? this.currency,
      promptpayId: promptpayId ?? this.promptpayId,
    );
  }

  @override
  List<Object?> get props => [currency, promptpayId];
}
