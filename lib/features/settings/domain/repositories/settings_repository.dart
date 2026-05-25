import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
