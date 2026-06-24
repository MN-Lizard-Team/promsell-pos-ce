import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

void main() {
  group('SettingsThemeExtension', () {
    test('light has expected defaults', () {
      expect(SettingsThemeExtension.light.cardRadius, 16);
      expect(SettingsThemeExtension.light.dividerIndent, 16);
      expect(SettingsThemeExtension.light.tileMinHeight, 64);
      expect(SettingsThemeExtension.light.iconSize, 48);
    });

    test('dark has expected defaults', () {
      expect(SettingsThemeExtension.dark.cardRadius, 16);
      expect(SettingsThemeExtension.dark.dividerIndent, 16);
    });

    test('copyWith updates fields', () {
      final updated = SettingsThemeExtension.light.copyWith(
        cardRadius: 24,
        iconSize: 56,
      );
      expect(updated.cardRadius, 24);
      expect(updated.iconSize, 56);
      expect(
        updated.cardBackground,
        SettingsThemeExtension.light.cardBackground,
      );
    });

    test('lerp interpolates between light and dark at t=0', () {
      final result = SettingsThemeExtension.light.lerp(
        SettingsThemeExtension.dark,
        0.0,
      );
      expect(
        result.cardBackground,
        SettingsThemeExtension.light.cardBackground,
      );
    });

    test('lerp interpolates between light and dark at t=1', () {
      final result = SettingsThemeExtension.light.lerp(
        SettingsThemeExtension.dark,
        1.0,
      );
      expect(result.cardBackground, SettingsThemeExtension.dark.cardBackground);
    });

    test('lerp returns self when other is not SettingsThemeExtension', () {
      final result = SettingsThemeExtension.light.lerp(null, 0.5);
      expect(result, same(SettingsThemeExtension.light));
    });
  });
}
