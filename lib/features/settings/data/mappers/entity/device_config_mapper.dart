import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';

class DeviceConfigMapper {
  Map<String, String> toMap(DeviceConfig device) {
    return {
      SettingsMapperKeys.keyDeviceId: device.deviceId,
      SettingsMapperKeys.keyDevicePrefix: device.devicePrefix,
    };
  }

  DeviceConfig fromMap(Map<String, String> map) {
    return DeviceConfig(
      deviceId: map[SettingsMapperKeys.keyDeviceId] ?? '',
      devicePrefix: map[SettingsMapperKeys.keyDevicePrefix] ?? '',
    );
  }
}
