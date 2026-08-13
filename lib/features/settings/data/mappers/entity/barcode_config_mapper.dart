import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';

class BarcodeConfigMapper {
  Map<String, String> toMap(BarcodeConfig barcode) {
    return {
      SettingsMapperKeys.keyBarcodeScanEnabled: barcode.scanEnabled.toString(),
      SettingsMapperKeys.keyBarcodeBeepOnScan: barcode.beepOnScan.toString(),
      SettingsMapperKeys.keyBarcodeAutoGeneratePrefix:
          barcode.autoGeneratePrefix,
      SettingsMapperKeys.keyBarcodeEnabledFormats: barcode.enabledFormats.join(
        ',',
      ),
      SettingsMapperKeys.keyBarcodeAutoOpenManualDelay: barcode
          .autoOpenManualDelay
          .toString(),
      SettingsMapperKeys.keyBarcodeLastCounter: barcode.lastCounter.toString(),
      SettingsMapperKeys.keyBarcodeContinuousScan: barcode.continuousScan
          .toString(),
    };
  }

  BarcodeConfig fromMap(Map<String, String> map) {
    return BarcodeConfig(
      scanEnabled: parseBool(
        map[SettingsMapperKeys.keyBarcodeScanEnabled],
        true,
      ),
      autoGeneratePrefix:
          map[SettingsMapperKeys.keyBarcodeAutoGeneratePrefix] ?? '200',
      beepOnScan: parseBool(map[SettingsMapperKeys.keyBarcodeBeepOnScan], true),
      enabledFormats: parseFormatList(
        map[SettingsMapperKeys.keyBarcodeEnabledFormats],
      ),
      autoOpenManualDelay: parseInt(
        map[SettingsMapperKeys.keyBarcodeAutoOpenManualDelay],
        0,
      ),
      lastCounter: parseInt(map[SettingsMapperKeys.keyBarcodeLastCounter], 0),
      continuousScan: parseBool(
        map[SettingsMapperKeys.keyBarcodeContinuousScan],
        true,
      ),
    );
  }
}
