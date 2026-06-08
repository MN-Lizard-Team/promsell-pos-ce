import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class SettingsPersistenceService {
  SettingsPersistenceService(this._repository);

  final SettingsRepository _repository;
  Timer? _saveTimer;

  void scheduleSave(AppSettings settings) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () {
      _save(settings);
    });
  }

  Future<void> saveImmediately(AppSettings settings) async {
    _saveTimer?.cancel();
    await _save(settings);
  }

  Future<void> _save(AppSettings settings) async {
    await _repository.save(settings.toSettings());
  }

  void dispose() {
    _saveTimer?.cancel();
  }
}
