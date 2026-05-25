part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, loaded, saving, saved, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const AppSettings(),
  });

  final SettingsStatus status;
  final AppSettings settings;

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettings? settings,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [status, settings];
}
