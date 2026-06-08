import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

abstract interface class SettingsRepository {
  Future<Settings> load();
  Future<void> save(Settings settings);
}
