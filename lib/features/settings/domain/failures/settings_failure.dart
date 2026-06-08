import 'package:equatable/equatable.dart';

sealed class SettingsFailure extends Equatable {
  const SettingsFailure();

  @override
  List<Object?> get props => [];
}

final class SettingsLoadFailure extends SettingsFailure {
  const SettingsLoadFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class SettingsSaveFailure extends SettingsFailure {
  const SettingsSaveFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class InvalidSettingsFailure extends SettingsFailure {
  const InvalidSettingsFailure(this.field);
  final String field;

  @override
  List<Object?> get props => [field];
}
