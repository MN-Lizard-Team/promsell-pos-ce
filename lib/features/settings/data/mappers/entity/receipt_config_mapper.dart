import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';

class ReceiptConfigMapper {
  Map<String, String> toMap(ReceiptConfig receipt) {
    return {
      SettingsMapperKeys.keyReceiptNote: receipt.receiptNote,
      SettingsMapperKeys.keyShowShopInfo: receipt.showShopInfo.toString(),
      SettingsMapperKeys.keyReceiptPreviewStyle: receipt.receiptPreviewStyle,
      SettingsMapperKeys.keyShowPreSalePreview: receipt.showPreSalePreview
          .toString(),
      SettingsMapperKeys.keyShowPostSalePreview: receipt.showPostSalePreview
          .toString(),
      SettingsMapperKeys.keyReceiptSize: receipt.receiptSize,
    };
  }

  ReceiptConfig fromMap(Map<String, String> map) {
    return ReceiptConfig(
      receiptSize: map[SettingsMapperKeys.keyReceiptSize] ?? '80mm',
      receiptPreviewStyle:
          map[SettingsMapperKeys.keyReceiptPreviewStyle] ?? 'thermal',
      receiptNote: parseString(
        map,
        SettingsMapperKeys.keyReceiptNote,
        legacy: SettingsMapperKeys.legacyReceiptNote,
      ),
      showShopInfo: parseBool(map[SettingsMapperKeys.keyShowShopInfo], true),
      showPreSalePreview: parseBool(
        map[SettingsMapperKeys.keyShowPreSalePreview],
        true,
      ),
      showPostSalePreview: parseBool(
        map[SettingsMapperKeys.keyShowPostSalePreview],
        true,
      ),
    );
  }
}
