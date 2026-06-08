import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class GetSettings {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  Future<(Settings?, SettingsFailure?)> call() async {
    try {
      final settings = await _repository.load();
      return (settings, null);
    } catch (e) {
      return (null, SettingsLoadFailure(e.toString()));
    }
  }
}
