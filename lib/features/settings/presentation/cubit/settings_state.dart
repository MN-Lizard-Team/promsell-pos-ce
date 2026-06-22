part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, loaded, saving, saved, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    Settings? settings,
    this.errorMessage,
  }) : settings = settings ?? const Settings();

  factory SettingsState.initial() => const SettingsState();

  final SettingsStatus status;
  final Settings settings;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    Settings? settings,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
