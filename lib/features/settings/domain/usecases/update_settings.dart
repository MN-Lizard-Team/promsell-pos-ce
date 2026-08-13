import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/services/settings_sensitive_fields.dart';

@injectable
class UpdateSettings {
  const UpdateSettings(this._repository, this._appLock);

  final SettingsRepository _repository;
  final AppLockService _appLock;

  Future<SettingsFailure?> call(Settings settings) async {
    try {
      final current = await _repository.load();
      if (settingsSensitivePaymentChanged(current, settings)) {
        await _appLock.requireSensitiveSession();
      }
      await _repository.save(settings);
      return null;
    } on BusinessRuleError {
      rethrow;
    } catch (e) {
      return SettingsSaveFailure(e.toString());
    }
  }
}
