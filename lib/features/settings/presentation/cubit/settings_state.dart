part of 'settings_cubit.dart';

enum SettingsStatus { initial, loading, loaded, saving, saved, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    Settings? settings,
    this.errorMessage,
    this.dbUnavailable = false,
  }) : settings = settings ?? const Settings();

  factory SettingsState.initial() => const SettingsState();

  final SettingsStatus status;
  final Settings settings;
  final String? errorMessage;

  /// True when the startup failure was caused by the SQLCipher key being
  /// unavailable (secure storage / Keystore error) — the splash wrapper then
  /// shows the recovery-kit gate instead of the normal shell.
  final bool dbUnavailable;

  SettingsState copyWith({
    SettingsStatus? status,
    Settings? settings,
    String? errorMessage,
    bool? dbUnavailable,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
      dbUnavailable: dbUnavailable ?? this.dbUnavailable,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage, dbUnavailable];
}
