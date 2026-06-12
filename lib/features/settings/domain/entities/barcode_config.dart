import 'package:equatable/equatable.dart';

class BarcodeConfig extends Equatable {
  const BarcodeConfig({
    this.scanEnabled = true,
    this.autoGeneratePrefix = 'P',
    this.beepOnScan = true,
  });

  final bool scanEnabled;
  final String autoGeneratePrefix;
  final bool beepOnScan;

  BarcodeConfig copyWith({
    bool? scanEnabled,
    String? autoGeneratePrefix,
    bool? beepOnScan,
  }) {
    return BarcodeConfig(
      scanEnabled: scanEnabled ?? this.scanEnabled,
      autoGeneratePrefix: autoGeneratePrefix ?? this.autoGeneratePrefix,
      beepOnScan: beepOnScan ?? this.beepOnScan,
    );
  }

  @override
  List<Object?> get props => [scanEnabled, autoGeneratePrefix, beepOnScan];
}
