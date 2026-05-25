import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final settings = await _repository.load();
      emit(state.copyWith(status: SettingsStatus.loaded, settings: settings));
    } catch (_) {
      emit(state.copyWith(status: SettingsStatus.failure));
    }
  }

  Future<void> update(AppSettings settings) async {
    final previous = state.settings;
    emit(state.copyWith(status: SettingsStatus.saving, settings: settings));
    try {
      await _repository.save(settings);
      emit(state.copyWith(status: SettingsStatus.saved));
    } catch (_) {
      emit(state.copyWith(status: SettingsStatus.failure, settings: previous));
    }
  }
}
