import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsRepositoryImpl', () {
    late SettingsRepositoryImpl repo;

    setUp(() {
      repo = SettingsRepositoryImpl();
    });

    test('load returns defaults when prefs are empty', () async {
      SharedPreferences.setMockInitialValues({});

      final settings = await repo.load();

      expect(settings.locale, const Locale('th'));
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.shopName, '');
      expect(settings.currency, '฿');
      expect(settings.showShopInfoOnReceipt, isTrue);
    });

    test('load returns saved values from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'locale': 'en',
        'theme': ThemeMode.dark.index,
        'shopName': 'My Shop',
        'currency': '\$',
        'showShopInfo': false,
      });

      final settings = await repo.load();

      expect(settings.locale, const Locale('en'));
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.shopName, 'My Shop');
      expect(settings.currency, '\$');
      expect(settings.showShopInfoOnReceipt, isFalse);
    });

    test('save persists all settings to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      const settings = AppSettings(
        locale: Locale('en'),
        themeMode: ThemeMode.light,
        shopName: 'Test Shop',
        address: '123 Street',
        phone: '0812345678',
        currency: '\$',
        dateFormat: 'yyyy-MM-dd',
        receiptNote: 'Thank you!',
        showShopInfoOnReceipt: false,
      );

      await repo.save(settings);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), 'en');
      expect(prefs.getInt('theme'), ThemeMode.light.index);
      expect(prefs.getString('shopName'), 'Test Shop');
      expect(prefs.getString('address'), '123 Street');
      expect(prefs.getString('phone'), '0812345678');
      expect(prefs.getString('currency'), '\$');
      expect(prefs.getString('dateFormat'), 'yyyy-MM-dd');
      expect(prefs.getString('receiptNote'), 'Thank you!');
      expect(prefs.getBool('showShopInfo'), isFalse);
    });

    test('load handles invalid theme index gracefully', () async {
      SharedPreferences.setMockInitialValues({'theme': 999});

      final settings = await repo.load();

      expect(settings.themeMode, ThemeMode.system);
    });
  });
}
