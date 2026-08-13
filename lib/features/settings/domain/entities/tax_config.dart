import 'package:equatable/equatable.dart';

class TaxConfig extends Equatable {
  const TaxConfig({this.vatRate = 7.0, this.vatMode = 'NONE'});

  /// Maximum allowed VAT rate (percent).
  static const double maxVatRate = 30;

  /// Minimum allowed VAT rate (percent).
  static const double minVatRate = 0;

  final double vatRate;
  final String vatMode;

  /// Returns `true` when [vatRate] is within the allowed range.
  bool get isVatRateValid =>
      vatRate >= minVatRate && vatRate <= maxVatRate && !vatRate.isNaN;

  /// Sanitizes [vatRate] to the allowed range.
  ///
  /// NaN and values outside [minVatRate, maxVatRate] are clamped.
  TaxConfig copyWith({double? vatRate, String? vatMode}) {
    final nextRate = vatRate ?? this.vatRate;
    final sanitizedRate = nextRate.isNaN
        ? this.vatRate
        : nextRate.clamp(minVatRate, maxVatRate);
    return TaxConfig(vatRate: sanitizedRate, vatMode: vatMode ?? this.vatMode);
  }

  @override
  List<Object?> get props => [vatRate, vatMode];
}
