import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';

class BusinessConfigMapper {
  Map<String, String> toMap(BusinessConfig business) {
    return {
      SettingsMapperKeys.keyBusinessType: business.businessType.name,
      SettingsMapperKeys.keyDefaultServiceChargeRate: business
          .defaultServiceChargeRate
          .toString(),
    };
  }

  BusinessConfig fromMap(Map<String, String> map) {
    return BusinessConfig(
      businessType: _parseBusinessType(map[SettingsMapperKeys.keyBusinessType]),
      defaultServiceChargeRate: parseDouble(
        map[SettingsMapperKeys.keyDefaultServiceChargeRate],
        0.0,
      ),
    );
  }

  BusinessType _parseBusinessType(String? raw) {
    if (raw == null || raw.isEmpty) return BusinessType.retail;
    for (final v in BusinessType.values) {
      if (v.name == raw) return v;
    }
    AppLogger.warning(
      'BusinessConfigMapper: unknown businessType "$raw" → retail',
    );
    return BusinessType.retail;
  }
}
