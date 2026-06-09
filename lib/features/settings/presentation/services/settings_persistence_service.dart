import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class SettingsPersistenceService {
  SettingsPersistenceService(this._repository);

  final SettingsRepository _repository;
  Timer? _saveTimer;
  AppSettings? _lastSettings;

  void scheduleSave(AppSettings settings) {
    _lastSettings = settings;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () {
      _save(settings);
    });
  }

  Future<void> saveImmediately(AppSettings settings) async {
    _lastSettings = settings;
    _saveTimer?.cancel();
    await _save(settings);
  }

  Future<void> _save(AppSettings settings) async {
    await _repository.save(settings.toSettings());
  }

  Future<void> dispose() async {
    _saveTimer?.cancel();
    if (_lastSettings != null) {
      await _save(_lastSettings!);
    }
  }
}
