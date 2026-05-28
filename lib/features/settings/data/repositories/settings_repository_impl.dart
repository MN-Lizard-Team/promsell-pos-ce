import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._datasource);

  final SettingsLocalDatasource _datasource;

  static const _keyLocale = 'locale';
  static const _keyTheme = 'theme';
  static const _keyShopName = 'shopName';
  static const _keyAddress = 'address';
  static const _keyPhone = 'phone';
  static const _keyCurrency = 'currency';
  static const _keyDateFormat = 'dateFormat';
  static const _keyReceiptNote = 'receiptNote';
  static const _keyShowShopInfo = 'showShopInfo';
  static const _keyAutoPrintPrompt = 'autoPrintPrompt';
  static const _keyVatRate = 'vatRate';
  static const _keyVatMode = 'vatMode';
  static const _keyReceiptPreviewStyle = 'receiptPreviewStyle';
  static const _keyShowPreSalePreview = 'showPreSalePreview';
  static const _keyShowPostSalePreview = 'showPostSalePreview';

  @override
  Future<AppSettings> load() async {
    final localeCode = await _datasource.getString(_keyLocale) ?? 'th';
    final themeIndex =
        await _datasource.getInt(_keyTheme) ?? ThemeMode.system.index;
    final safeThemeIndex =
        (themeIndex >= 0 && themeIndex < ThemeMode.values.length)
        ? themeIndex
        : ThemeMode.system.index;

    return AppSettings(
      locale: Locale(localeCode),
      themeMode: ThemeMode.values[safeThemeIndex],
      shopName: await _datasource.getString(_keyShopName) ?? '',
      address: await _datasource.getString(_keyAddress) ?? '',
      phone: await _datasource.getString(_keyPhone) ?? '',
      currency: await _datasource.getString(_keyCurrency) ?? '฿',
      dateFormat: await _datasource.getString(_keyDateFormat) ?? 'dd/MM/yyyy',
      receiptNote: await _datasource.getString(_keyReceiptNote) ?? '',
      showShopInfoOnReceipt:
          await _datasource.getBool(_keyShowShopInfo) ?? true,
      autoPrintPrompt: await _datasource.getBool(_keyAutoPrintPrompt) ?? true,
      vatRate: await _datasource.getDouble(_keyVatRate) ?? 7.0,
      vatMode: await _datasource.getString(_keyVatMode) ?? 'NONE',
      receiptPreviewStyle:
          await _datasource.getString(_keyReceiptPreviewStyle) ?? 'thermal',
      showPreSalePreview:
          await _datasource.getBool(_keyShowPreSalePreview) ?? true,
      showPostSalePreview:
          await _datasource.getBool(_keyShowPostSalePreview) ?? true,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _datasource.setString(_keyLocale, settings.locale.languageCode);
    await _datasource.setInt(_keyTheme, settings.themeMode.index);
    await _datasource.setString(_keyShopName, settings.shopName);
    await _datasource.setString(_keyAddress, settings.address);
    await _datasource.setString(_keyPhone, settings.phone);
    await _datasource.setString(_keyCurrency, settings.currency);
    await _datasource.setString(_keyDateFormat, settings.dateFormat);
    await _datasource.setString(_keyReceiptNote, settings.receiptNote);
    await _datasource.setBool(_keyShowShopInfo, settings.showShopInfoOnReceipt);
    await _datasource.setBool(_keyAutoPrintPrompt, settings.autoPrintPrompt);
    await _datasource.setDouble(_keyVatRate, settings.vatRate);
    await _datasource.setString(_keyVatMode, settings.vatMode);
    await _datasource.setString(
      _keyReceiptPreviewStyle,
      settings.receiptPreviewStyle,
    );
    await _datasource.setBool(
      _keyShowPreSalePreview,
      settings.showPreSalePreview,
    );
    await _datasource.setBool(
      _keyShowPostSalePreview,
      settings.showPostSalePreview,
    );
  }
}
