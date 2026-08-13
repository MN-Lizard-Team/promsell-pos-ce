import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';

class TaxConfigMapper {
  Map<String, String> toMap(TaxConfig tax) {
    return {
      SettingsMapperKeys.keyVatRate: tax.vatRate.toString(),
      SettingsMapperKeys.keyVatMode: tax.vatMode,
    };
  }

  TaxConfig fromMap(Map<String, String> map) {
    return TaxConfig(
      vatRate: parseDouble(
        map[SettingsMapperKeys.keyVatRate] ??
            map[SettingsMapperKeys.legacyVatRate],
        7.0,
      ),
      vatMode:
          map[SettingsMapperKeys.keyVatMode] ??
          map[SettingsMapperKeys.legacyVatMode] ??
          'NONE',
    );
  }
}
