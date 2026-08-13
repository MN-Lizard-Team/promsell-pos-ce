import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/ui_config.dart';

class UiConfigMapper {
  Map<String, String> toMap(UiConfig ui) {
    return {
      SettingsMapperKeys.keyLocale: ui.locale,
      SettingsMapperKeys.keyTheme: ui.themeMode,
      SettingsMapperKeys.keyDateFormat: ui.dateFormat,
      SettingsMapperKeys.keyUltraCompactMode: ui.ultraCompactMode.toString(),
      SettingsMapperKeys.keyAccessibilityMode: ui.accessibilityMode.toString(),
    };
  }

  UiConfig fromMap(Map<String, String> map) {
    return UiConfig(
      locale: map[SettingsMapperKeys.keyLocale] ?? 'th',
      themeMode: parseThemeMode(map[SettingsMapperKeys.keyTheme]),
      dateFormat: map[SettingsMapperKeys.keyDateFormat] ?? 'dd/MM/yyyy',
      ultraCompactMode: parseBool(
        map[SettingsMapperKeys.keyUltraCompactMode],
        false,
      ),
      accessibilityMode: parseBool(
        map[SettingsMapperKeys.keyAccessibilityMode],
        false,
      ),
    );
  }
}
