import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class UpdateSettings {
  const UpdateSettings(this._repository);

  final SettingsRepository _repository;

  Future<SettingsFailure?> call(Settings settings) async {
    try {
      await _repository.save(settings);
      return null;
    } catch (e) {
      return SettingsSaveFailure(e.toString());
    }
  }
}
