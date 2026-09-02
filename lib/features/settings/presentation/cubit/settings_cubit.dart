import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/database/db_key_store.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/presentation/services/settings_persistence_service.dart';

part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._repository,
    this._persistenceService,
    this._barcodeGenerator, {
    @Named('settingsLoadTimeout')
    this.loadTimeout = const Duration(seconds: 12),
  }) : super(const SettingsState()) {
    _persistenceService.onDebouncedSaveError = _onDebouncedSaveError;
  }

  final SettingsRepository _repository;
  final SettingsPersistenceService _persistenceService;
  final Ean13Generator _barcodeGenerator;

  /// Upper bound for the startup settings read. Secure storage / first-run
  /// DB creation can hang on a broken Keystore — timing out emits failure
  /// (fail-safe → onboarding) instead of freezing the app on the splash.
  final Duration loadTimeout;

  void _onDebouncedSaveError(Object error) {
    if (isClosed) return;
    AppLogger.error('SettingsCubit debounced save failed', error: error);
    emit(
      state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: error.toString(),
      ),
    );
  }

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    try {
      final settings = await _repository.load().timeout(loadTimeout);
      _barcodeGenerator.initCounter(settings.barcodeLastCounter);
      emit(
        state.copyWith(
          status: SettingsStatus.loaded,
          settings: settings,
          dbUnavailable: false,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('SettingsCubit.load failed', error: e, stack: stack);
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
          dbUnavailable: _isDbKeyUnavailable(e),
        ),
      );
    }
  }

  /// Detects SQLCipher key unavailability across exception wrapping — Drift
  /// may surface the original [DbKeyUnavailable] directly or rethrow it from
  /// the background isolate with the type name embedded in the message.
  bool _isDbKeyUnavailable(Object e) =>
      e is DbKeyUnavailable || e.toString().contains('DbKeyUnavailable');

  void updateField(Settings Function(Settings) mapper) {
    final updated = mapper(state.settings);
    emit(
      state.copyWith(
        status: SettingsStatus.loaded,
        settings: updated,
        errorMessage: null,
      ),
    );
    _persistenceService.scheduleSave(updated);
  }

  Future<bool> saveAndApply(Settings settings) async {
    final previous = state.settings;
    emit(state.copyWith(status: SettingsStatus.saving));
    try {
      await _persistenceService.saveImmediately(settings);
      emit(SettingsState(status: SettingsStatus.saved, settings: settings));
      return true;
    } catch (e) {
      emit(
        SettingsState(
          status: SettingsStatus.failure,
          settings: previous,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> update(Settings settings) async {
    final previous = state.settings;
    emit(
      state.copyWith(
        status: SettingsStatus.saving,
        settings: settings,
        errorMessage: null,
      ),
    );
    try {
      await _persistenceService.saveImmediately(settings);
      emit(state.copyWith(status: SettingsStatus.saved));
    } catch (e) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          settings: previous,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _persistenceService.onDebouncedSaveError = null;
    await _persistenceService.dispose();
    return super.close();
  }
}
