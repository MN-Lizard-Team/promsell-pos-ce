import 'package:equatable/equatable.dart';

class BarcodeConfig extends Equatable {
  const BarcodeConfig({
    this.scanEnabled = true,
    this.autoGeneratePrefix = '200',
    this.beepOnScan = true,
    this.enabledFormats = defaultAllFormats,
    this.autoOpenManualDelay = 0,
    this.lastCounter = 0,
  });

  static const defaultAllFormats = <String>[
    'ean13',
    'ean8',
    'upcA',
    'upcE',
    'code128',
    'code39',
    'itf',
    'qrCode',
    'dataMatrix',
    'pdf417',
    'aztec',
    'codabar',
  ];

  final bool scanEnabled;
  final String autoGeneratePrefix;
  final bool beepOnScan;
  final List<String> enabledFormats;
  final int autoOpenManualDelay;
  final int lastCounter;

  BarcodeConfig copyWith({
    bool? scanEnabled,
    String? autoGeneratePrefix,
    bool? beepOnScan,
    List<String>? enabledFormats,
    int? autoOpenManualDelay,
    int? lastCounter,
  }) {
    return BarcodeConfig(
      scanEnabled: scanEnabled ?? this.scanEnabled,
      autoGeneratePrefix: autoGeneratePrefix ?? this.autoGeneratePrefix,
      beepOnScan: beepOnScan ?? this.beepOnScan,
      enabledFormats: enabledFormats ?? this.enabledFormats,
      autoOpenManualDelay: autoOpenManualDelay ?? this.autoOpenManualDelay,
      lastCounter: lastCounter ?? this.lastCounter,
    );
  }

  @override
  List<Object?> get props => [
    scanEnabled,
    autoGeneratePrefix,
    beepOnScan,
    enabledFormats,
    autoOpenManualDelay,
    lastCounter,
  ];
}
