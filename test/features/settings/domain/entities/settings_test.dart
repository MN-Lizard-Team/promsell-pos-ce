import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

void main() {
  group('Settings defaults', () {
    test('default localeCode is th', () {
      const settings = Settings();
      expect(settings.localeCode, 'th');
    });

    test('default themeModeName is system', () {
      const settings = Settings();
      expect(settings.themeModeName, 'system');
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

    test('updates themeModeName', () {
      const settings = Settings();
      final updated = settings.copyWith(themeModeName: 'dark');
      expect(updated.themeModeName, 'dark');
    });

    test('updates localeCode', () {
      const settings = Settings();
      final updated = settings.copyWith(localeCode: 'en');
      expect(updated.localeCode, 'en');
    });

    test('updates allowOversell', () {
      const settings = Settings();
      final updated = settings.copyWith(allowOversell: true);
      expect(updated.allowOversell, isTrue);
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
