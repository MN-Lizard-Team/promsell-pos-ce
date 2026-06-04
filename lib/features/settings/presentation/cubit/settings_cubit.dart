import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;
  Timer? _saveTimer;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    try {
      final settings = await _repository.load();
      emit(state.copyWith(status: SettingsStatus.loaded, settings: settings));
    } catch (e) {
      debugPrint('SettingsCubit.load failed: $e');
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void updateField(AppSettings Function(AppSettings) mapper) {
    final updated = mapper(state.settings);
    emit(
      state.copyWith(
        status: SettingsStatus.loaded,
        settings: updated,
        errorMessage: null,
      ),
    );
    _debounceSave(updated);
  }

  void _debounceSave(AppSettings settings) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () {
      _save(settings);
    });
  }

  Future<void> _save(AppSettings settings) async {
    final previous = state.settings;
    emit(
      state.copyWith(
        status: SettingsStatus.saving,
        settings: settings,
        errorMessage: null,
      ),
    );
    try {
      await _repository.save(settings);
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

  Future<void> update(AppSettings settings) async {
    _saveTimer?.cancel();
    await _save(settings);
  }

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
