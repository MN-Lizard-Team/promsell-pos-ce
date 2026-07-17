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

  /// Optional listener for debounced save failures (UI snack / cubit).
  void Function(Object error)? onDebouncedSaveError;

  void scheduleSave(Settings settings) {
    if (_isDisposed) return;
    _lastSettings = settings;
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () {
      if (!_isDisposed) unawaited(_saveDebounced(settings));
    });
  }

  Future<void> saveImmediately(Settings settings) async {
    if (_isDisposed) return;
    _lastSettings = settings;
    _saveTimer?.cancel();
    await _saveOrThrow(settings);
  }

  Future<void> _saveDebounced(Settings settings) async {
    try {
      await _saveOrThrow(settings);
    } catch (e) {
      onDebouncedSaveError?.call(e);
    }
  }

  Future<void> _saveOrThrow(Settings settings) async {
    if (_isDisposed) return;
    try {
      await _repository.save(settings);
    } catch (e, stack) {
      AppLogger.error(
        'SettingsPersistenceService._save failed',
        error: e,
        stack: stack,
      );
      rethrow;
    }
  }

  Future<void> dispose() async {
    _saveTimer?.cancel();
    final pending = _lastSettings;
    _isDisposed = true;
    if (pending != null) {
      try {
        await _repository.save(pending);
      } catch (e, stack) {
        AppLogger.error(
          'SettingsPersistenceService.dispose flush failed',
          error: e,
          stack: stack,
        );
      }
    }
  }
}
