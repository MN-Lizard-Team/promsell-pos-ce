import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';

class PaymentConfigMapper {
  Map<String, String> toMap(PaymentConfig payment) {
    return {
      SettingsMapperKeys.keyCurrency: payment.currency,
      SettingsMapperKeys.keyPromptpayId: payment.promptpayId,
      SettingsMapperKeys.keyBillerId: payment.billerId,
      SettingsMapperKeys.keyPromptPayTimeout: payment.promptPayTimeout
          .toString(),
      SettingsMapperKeys.keyPromptPaySoundEnabled: payment.promptPaySoundEnabled
          .toString(),
      SettingsMapperKeys.keyDefaultQrType: payment.defaultQrType,
      SettingsMapperKeys.keyAutoConfirmAfterSlip: payment.autoConfirmAfterSlip
          .toString(),
      SettingsMapperKeys.keyQrOverlayIcon: payment.qrOverlayIcon,
    };
  }

  PaymentConfig fromMap(Map<String, String> map) {
    return PaymentConfig(
      currency: parseString(
        map,
        SettingsMapperKeys.keyCurrency,
        legacy: SettingsMapperKeys.legacyCurrency,
        or: '฿',
      ),
      promptpayId: map[SettingsMapperKeys.keyPromptpayId] ?? '',
      billerId: map[SettingsMapperKeys.keyBillerId] ?? '',
      promptPayTimeout: parseInt(
        map[SettingsMapperKeys.keyPromptPayTimeout],
        180,
      ),
      promptPaySoundEnabled: parseBool(
        map[SettingsMapperKeys.keyPromptPaySoundEnabled],
        true,
      ),
      defaultQrType: map[SettingsMapperKeys.keyDefaultQrType] ?? 'transfer',
      autoConfirmAfterSlip: parseBool(
        map[SettingsMapperKeys.keyAutoConfirmAfterSlip],
        false,
      ),
      qrOverlayIcon: map[SettingsMapperKeys.keyQrOverlayIcon] ?? '',
    );
  }
}
