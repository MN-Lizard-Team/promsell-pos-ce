import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/failures/settings_failure.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/services/settings_sensitive_fields.dart';

@injectable
class UpdateSettingGroup {
  const UpdateSettingGroup(this._repository, this._appLock);

  final SettingsRepository _repository;
  final AppLockService _appLock;

  Future<(Settings?, SettingsFailure?)> call(
    Settings current,
    Settings Function(Settings) mapper,
  ) async {
    try {
      final updated = mapper(current);
      if (settingsSensitivePaymentChanged(current, updated)) {
        await _appLock.requireSensitiveSession();
      }
      await _repository.save(updated);
      return (updated, null);
    } on BusinessRuleError {
      rethrow;
    } catch (e) {
      return (current, SettingsSaveFailure(e.toString()));
    }
  }
}
