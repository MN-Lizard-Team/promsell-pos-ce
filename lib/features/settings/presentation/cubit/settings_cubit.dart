import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/presentation/services/settings_persistence_service.dart';

part 'settings_state.dart';

@lazySingleton
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository, this._persistenceService)
    : super(SettingsState());

  final SettingsRepository _repository;
  final SettingsPersistenceService _persistenceService;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: null));
    try {
      final settings = await _repository.load();
      emit(
        state.copyWith(
          status: SettingsStatus.loaded,
          settings: AppSettings.fromSettings(settings),
        ),
      );
    } catch (e, stack) {
      AppLogger.error('SettingsCubit.load failed', error: e, stack: stack);
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
    _persistenceService.scheduleSave(updated);
  }

  Future<void> update(AppSettings settings) async {
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
    await _persistenceService.dispose();
    return super.close();
  }
}
