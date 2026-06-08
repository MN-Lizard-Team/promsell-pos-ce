import 'package:equatable/equatable.dart';

class TaxConfig extends Equatable {
  const TaxConfig({this.vatRate = 7.0, this.vatMode = 'NONE'});

  final double vatRate;
  final String vatMode;

  TaxConfig copyWith({double? vatRate, String? vatMode}) {
    return TaxConfig(
      vatRate: vatRate ?? this.vatRate,
      vatMode: vatMode ?? this.vatMode,
    );
  }

  @override
  List<Object?> get props => [vatRate, vatMode];
}
