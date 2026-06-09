import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  @override
  Future<Settings> load() async => const Settings(
    deviceConfig: DeviceConfig(deviceId: 'test-device', devicePrefix: 'T1'),
  );

  @override
  Future<void> save(Settings settings) async {}
}
