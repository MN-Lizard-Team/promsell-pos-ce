import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('has correct defaults', () {
      const settings = AppSettings();
      expect(settings.locale, const Locale('th'));
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.shopName, '');
      expect(settings.currency, '฿');
      expect(settings.dateFormat, 'dd/MM/yyyy');
      expect(settings.showShopInfoOnReceipt, isTrue);
    });

    test('supports value equality', () {
      const a = AppSettings();
      const b = AppSettings();
      expect(a, equals(b));
    });

    test('copyWith updates selected fields', () {
      const settings = AppSettings();
      final updated = settings.copyWith(
        shopName: 'My Shop',
        currency: '\$',
        themeMode: ThemeMode.dark,
      );
      expect(updated.shopName, 'My Shop');
      expect(updated.currency, '\$');
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.locale, const Locale('th'));
    });

    test('props contains all fields', () {
      const settings = AppSettings();
      expect(settings.props.length, 9);
    });
  });
}
