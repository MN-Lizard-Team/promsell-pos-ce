import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

void main() {
  group('Settings defaults', () {
    test('default locale is th', () {
      const settings = Settings();
      expect(settings.locale, const Locale('th'));
    });

    test('default themeMode is system', () {
      const settings = Settings();
      expect(settings.themeMode, ThemeMode.system);
    });

    test('default currency is ฿', () {
      const settings = Settings();
      expect(settings.currency, '฿');
    });

    test('default vatMode is NONE', () {
      const settings = Settings();
      expect(settings.vatMode, 'NONE');
    });

    test('default onboardingCompleted is false', () {
      const settings = Settings();
      expect(settings.onboardingCompleted, isFalse);
    });
  });

  group('Settings.copyWith', () {
    test('updates shopName', () {
      const settings = Settings();
      final updated = settings.copyWith(shopName: 'My Shop');
      expect(updated.shopName, 'My Shop');
    });

    test('updates currency', () {
      const settings = Settings();
      final updated = settings.copyWith(currency: '\$');
      expect(updated.currency, '\$');
    });

    test('updates vatMode and vatRate', () {
      const settings = Settings();
      final updated = settings.copyWith(vatMode: 'INCLUSIVE', vatRate: 7.0);
      expect(updated.vatMode, 'INCLUSIVE');
      expect(updated.vatRate, 7.0);
    });

    test('updates themeMode', () {
      const settings = Settings();
      final updated = settings.copyWith(themeMode: ThemeMode.dark);
      expect(updated.themeMode, ThemeMode.dark);
    });

    test('updates locale', () {
      const settings = Settings();
      final updated = settings.copyWith(locale: const Locale('en'));
      expect(updated.locale, const Locale('en'));
    });

    test('updates allowOversell', () {
      const settings = Settings();
      final updated = settings.copyWith(allowOversell: true);
      expect(updated.allowOversell, isTrue);
    });

    test('updates cartCompactMode', () {
      const settings = Settings();
      final updated = settings.copyWith(cartCompactMode: true);
      expect(updated.cartCompactMode, isTrue);
    });

    test('updates accessibilityMode', () {
      const settings = Settings();
      final updated = settings.copyWith(accessibilityMode: true);
      expect(updated.accessibilityMode, isTrue);
    });

    test('updates dailyCloseLock', () {
      const settings = Settings();
      final updated = settings.copyWith(dailyCloseLock: true);
      expect(updated.dailyCloseLock, isTrue);
    });

    test('updates promptpayId', () {
      const settings = Settings();
      final updated = settings.copyWith(promptpayId: '0812345678');
      expect(updated.promptpayId, '0812345678');
    });

    test('preserves unchanged fields', () {
      const settings = Settings();
      final updated = settings.copyWith(shopName: 'New');
      expect(updated.currency, settings.currency);
      expect(updated.vatMode, settings.vatMode);
    });
  });
}
