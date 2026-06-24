import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class SettingsPersistenceService {
  SettingsPersistenceService(this._repository);

  final SettingsRepository _repository;
  Timer? _saveTimer;
  Settings? _lastSettings;
  bool _isDisposed = false;

  void scheduleSave(Settings settings) {
    if (_isDisposed) return;
    _lastSettings = settings;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () {
      if (!_isDisposed) _save(settings);
    });
  }

  Future<void> saveImmediately(Settings settings) async {
    if (_isDisposed) return;
    _lastSettings = settings;
    _saveTimer?.cancel();
    await _save(settings);
  }

  Future<void> _save(Settings settings) async {
    if (_isDisposed) return;
    try {
      await _repository.save(settings);
    } catch (e, stack) {
      AppLogger.error(
        'SettingsPersistenceService._save failed',
        error: e,
        stack: stack,
      );
    }
  }

  Future<void> dispose() async {
    _saveTimer?.cancel();
    if (_lastSettings != null) {
      await _repository.save(_lastSettings!);
    }
    _isDisposed = true;
  }
}
