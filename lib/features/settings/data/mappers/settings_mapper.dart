import 'package:promsell_pos_ce/features/settings/data/mappers/entity/backup_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/barcode_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/business_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/daily_close_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/device_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/discount_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/draft_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/image_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/payment_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/receipt_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/shop_info_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/stock_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/tax_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/ui_config_mapper.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Thin facade that delegates to per-entity mappers.
///
/// Kept for backwards compatibility with [SettingsRepositoryImpl] and the
/// existing tests. New code should prefer the per-entity mappers in
/// `entity/` directly.
class SettingsMapper {
  static const keyBarcodeLastCounter = SettingsMapperKeys.keyBarcodeLastCounter;
  static const keySkuLastCounter = SettingsMapperKeys.keySkuLastCounter;

  final ShopInfoMapper _shopInfoMapper = ShopInfoMapper();
  final ReceiptConfigMapper _receiptConfigMapper = ReceiptConfigMapper();
  final TaxConfigMapper _taxConfigMapper = TaxConfigMapper();
  final DiscountConfigMapper _discountConfigMapper = DiscountConfigMapper();
  final StockConfigMapper _stockConfigMapper = StockConfigMapper();
  final ImageConfigMapper _imageConfigMapper = ImageConfigMapper();
  final PaymentConfigMapper _paymentConfigMapper = PaymentConfigMapper();
  final DeviceConfigMapper _deviceConfigMapper = DeviceConfigMapper();
  final UiConfigMapper _uiConfigMapper = UiConfigMapper();
  final DailyCloseConfigMapper _dailyCloseConfigMapper =
      DailyCloseConfigMapper();
  final BackupConfigMapper _backupConfigMapper = BackupConfigMapper();
  final DraftConfigMapper _draftConfigMapper = DraftConfigMapper();
  final BarcodeConfigMapper _barcodeConfigMapper = BarcodeConfigMapper();
  final BusinessConfigMapper _businessConfigMapper = BusinessConfigMapper();

  Map<String, String> toMap(Settings settings) {
    return {
      ..._shopInfoMapper.toMap(settings.shopInfo),
      ..._receiptConfigMapper.toMap(settings.receiptConfig),
      ..._taxConfigMapper.toMap(settings.taxConfig),
      ..._discountConfigMapper.toMap(settings.discountConfig),
      ..._stockConfigMapper.toMap(settings.stockConfig),
      ..._imageConfigMapper.toMap(settings.imageConfig),
      ..._paymentConfigMapper.toMap(settings.paymentConfig),
      ..._deviceConfigMapper.toMap(settings.deviceConfig),
      ..._uiConfigMapper.toMap(settings.uiConfig),
      ..._dailyCloseConfigMapper.toMap(settings.dailyCloseConfig),
      ..._backupConfigMapper.toMap(settings.backupConfig),
      ..._draftConfigMapper.toMap(settings.draftConfig),
      ..._barcodeConfigMapper.toMap(settings.barcodeConfig),
      ..._businessConfigMapper.toMap(settings.businessConfig),
      SettingsMapperKeys.keyOnboardingCompleted: settings.onboardingCompleted
          .toString(),
      SettingsMapperKeys.keySkuLastCounter: settings.skuLastCounter.toString(),
      SettingsMapperKeys.keySkuAutoGeneratePrefix:
          settings.skuAutoGeneratePrefix,
    };
  }

  Settings fromMap(Map<String, String> map) {
    return Settings(
      shopInfo: _shopInfoMapper.fromMap(map),
      receiptConfig: _receiptConfigMapper.fromMap(map),
      taxConfig: _taxConfigMapper.fromMap(map),
      discountConfig: _discountConfigMapper.fromMap(map),
      stockConfig: _stockConfigMapper.fromMap(map),
      imageConfig: _imageConfigMapper.fromMap(map),
      paymentConfig: _paymentConfigMapper.fromMap(map),
      deviceConfig: _deviceConfigMapper.fromMap(map),
      uiConfig: _uiConfigMapper.fromMap(map),
      dailyCloseConfig: _dailyCloseConfigMapper.fromMap(map),
      backupConfig: _backupConfigMapper.fromMap(map),
      draftConfig: _draftConfigMapper.fromMap(map),
      barcodeConfig: _barcodeConfigMapper.fromMap(map),
      businessConfig: _businessConfigMapper.fromMap(map),
      onboardingCompleted: parseBool(
        map[SettingsMapperKeys.keyOnboardingCompleted],
        false,
      ),
      skuLastCounter: parseInt(map[SettingsMapperKeys.keySkuLastCounter], 0),
      skuAutoGeneratePrefix:
          map[SettingsMapperKeys.keySkuAutoGeneratePrefix] ?? 'SKU',
    );
  }
}
