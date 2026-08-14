import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Presentation-only mapping from domain string codes to Flutter
/// `Locale` / `ThemeMode`. The domain `Settings` entity stores only
/// string codes (`localeCode`, `themeModeName`) so it never imports
/// Flutter.
Locale settingsLocale(Settings s) => Locale(s.localeCode);

ThemeMode settingsThemeMode(Settings s) {
  try {
    return ThemeMode.values.byName(s.themeModeName);
  } catch (_) {
    return ThemeMode.system;
  }
}
