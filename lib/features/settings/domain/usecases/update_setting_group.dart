import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class UpdateSettingGroup {
  const UpdateSettingGroup(this._repository);

  final SettingsRepository _repository;

  Future<(Settings?, SettingsFailure?)> call(
    Settings current,
    Settings Function(Settings) mapper,
  ) async {
    try {
      final updated = mapper(current);
      await _repository.save(updated);
      return (updated, null);
    } catch (e) {
      return (current, SettingsSaveFailure(e.toString()));
    }
  }
}
