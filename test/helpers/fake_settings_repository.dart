import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({this.allowOversell = false});

  bool allowOversell;

  @override
  Future<Settings> load() async => Settings(
    deviceConfig: const DeviceConfig(
      deviceId: 'test-device',
      devicePrefix: 'T1',
    ),
    stockConfig: StockConfig(allowOversell: allowOversell),
  );

  @override
  Future<void> save(Settings settings) async {}

  @override
  Future<void> saveBarcodeLastCounter(int counter) async {}
}
