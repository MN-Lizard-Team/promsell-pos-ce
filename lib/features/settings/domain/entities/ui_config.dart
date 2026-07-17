import 'package:equatable/equatable.dart';

class UiConfig extends Equatable {
  const UiConfig({
    this.locale = 'th',
    this.themeMode = 'system',
    this.dateFormat = 'dd/MM/yyyy',
    this.ultraCompactMode = false,
    this.accessibilityMode = false,
  });

  final String locale;
  final String themeMode;
  final String dateFormat;
  final bool ultraCompactMode;
  final bool accessibilityMode;

  UiConfig copyWith({
    String? locale,
    String? themeMode,
    String? dateFormat,
    bool? ultraCompactMode,
    bool? accessibilityMode,
  }) {
    return UiConfig(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      dateFormat: dateFormat ?? this.dateFormat,
      ultraCompactMode: ultraCompactMode ?? this.ultraCompactMode,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    themeMode,
    dateFormat,
    ultraCompactMode,
    accessibilityMode,
  ];
}
