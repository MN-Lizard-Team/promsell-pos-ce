import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const _keyLocale = 'locale';
  static const _keyTheme = 'theme';
  static const _keyShopName = 'shopName';
  static const _keyAddress = 'address';
  static const _keyPhone = 'phone';
  static const _keyCurrency = 'currency';
  static const _keyDateFormat = 'dateFormat';
  static const _keyReceiptNote = 'receiptNote';
  static const _keyShowShopInfo = 'showShopInfo';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_keyLocale) ?? 'th';
    final themeIndex = prefs.getInt(_keyTheme) ?? ThemeMode.system.index;

    return AppSettings(
      locale: Locale(localeCode),
      themeMode: ThemeMode.values[themeIndex],
      shopName: prefs.getString(_keyShopName) ?? '',
      address: prefs.getString(_keyAddress) ?? '',
      phone: prefs.getString(_keyPhone) ?? '',
      currency: prefs.getString(_keyCurrency) ?? '฿',
      dateFormat: prefs.getString(_keyDateFormat) ?? 'dd/MM/yyyy',
      receiptNote: prefs.getString(_keyReceiptNote) ?? '',
      showShopInfoOnReceipt: prefs.getBool(_keyShowShopInfo) ?? true,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, settings.locale.languageCode);
    await prefs.setInt(_keyTheme, settings.themeMode.index);
    await prefs.setString(_keyShopName, settings.shopName);
    await prefs.setString(_keyAddress, settings.address);
    await prefs.setString(_keyPhone, settings.phone);
    await prefs.setString(_keyCurrency, settings.currency);
    await prefs.setString(_keyDateFormat, settings.dateFormat);
    await prefs.setString(_keyReceiptNote, settings.receiptNote);
    await prefs.setBool(_keyShowShopInfo, settings.showShopInfoOnReceipt);
  }
}
