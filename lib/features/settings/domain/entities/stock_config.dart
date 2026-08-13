import 'package:equatable/equatable.dart';

class StockConfig extends Equatable {
  const StockConfig({this.allowOversell = false, this.lowStockThreshold = 5})
    : assert(lowStockThreshold >= 1, 'lowStockThreshold must be at least 1');

  final bool allowOversell;
  final int lowStockThreshold;

  StockConfig copyWith({bool? allowOversell, int? lowStockThreshold}) {
    return StockConfig(
      allowOversell: allowOversell ?? this.allowOversell,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    );
  }

  @override
  List<Object?> get props => [allowOversell, lowStockThreshold];
}
