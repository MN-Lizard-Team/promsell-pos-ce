part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, loaded, saving, saved, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const AppSettings(),
    this.errorMessage,
  });

  final SettingsStatus status;
  final AppSettings settings;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettings? settings,
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
