import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@LazySingleton(as: SettingsRepository)
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
  static const _keyAllowOversell = 'allowOversell';
  static const _keyLowStockThreshold = 'lowStockThreshold';
  static const _keyEnableItemDiscount = 'enableItemDiscount';
  static const _keyEnableCartDiscount = 'enableCartDiscount';
  static const _keyMaxDiscountPercent = 'maxDiscountPercent';
  static const _keyDefaultDiscountType = 'defaultDiscountType';
  static const _keyDiscountPresets = 'discountPresets';
  static const _keyMaxDiscountAmount = 'maxDiscountAmount';
  static const _keyActiveDiscountPresetId = 'activeDiscountPresetId';
  static const _keyPresetDiscountValues = 'presetDiscountValues';
  static const _keyPromptpayId = 'promptpayId';
  static const _keyReceiptSize = 'receiptSize';
  static const _keyBackupReminderDays = 'backupReminderDays';
  static const _keyLastBackupAt = 'lastBackupAt';
  static const _keyImageMaxWidth = 'imageMaxWidth';
  static const _keyImageQuality = 'imageQuality';
  static const _keyMaxDrafts = 'maxDrafts';
  static const _keyCartCompactMode = 'cartCompactMode';
  static const _keyUltraCompactMode = 'ultraCompactMode';

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
      allowOversell: await _datasource.getBool(_keyAllowOversell) ?? false,
      lowStockThreshold: await _datasource.getInt(_keyLowStockThreshold) ?? 5,
      enableItemDiscount:
          await _datasource.getBool(_keyEnableItemDiscount) ?? true,
      enableCartDiscount:
          await _datasource.getBool(_keyEnableCartDiscount) ?? true,
      maxDiscountPercent:
          await _datasource.getDouble(_keyMaxDiscountPercent) ?? 100.0,
      defaultDiscountType:
          await _datasource.getString(_keyDefaultDiscountType) ?? 'PERCENT',
      maxDiscountAmount:
          await _datasource.getDouble(_keyMaxDiscountAmount) ?? 0.0,
      discountPresets: await _loadDiscountPresets(),
      activeDiscountPresetId:
          await _datasource.getString(_keyActiveDiscountPresetId) ?? 'default',
      promptpayId: await _datasource.getString(_keyPromptpayId) ?? '',
      receiptSize: await _datasource.getString(_keyReceiptSize) ?? '80mm',
      backupReminderDays: await _datasource.getInt(_keyBackupReminderDays) ?? 7,
      lastBackupAt: await _datasource.getString(_keyLastBackupAt),
      imageMaxWidth: await _datasource.getInt(_keyImageMaxWidth) ?? 800,
      imageQuality: await _datasource.getInt(_keyImageQuality) ?? 80,
      maxDrafts: await _datasource.getInt(_keyMaxDrafts) ?? 30,
      cartCompactMode: await _datasource.getBool(_keyCartCompactMode) ?? false,
      ultraCompactMode: await _datasource.getBool(_keyUltraCompactMode) ?? false,
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
    await _datasource.setBool(_keyAllowOversell, settings.allowOversell);
    await _datasource.setInt(_keyLowStockThreshold, settings.lowStockThreshold);
    await _datasource.setBool(
      _keyEnableItemDiscount,
      settings.enableItemDiscount,
    );
    await _datasource.setBool(
      _keyEnableCartDiscount,
      settings.enableCartDiscount,
    );
    await _datasource.setDouble(
      _keyMaxDiscountPercent,
      settings.maxDiscountPercent,
    );
    await _datasource.setString(
      _keyDefaultDiscountType,
      settings.defaultDiscountType,
    );
    await _datasource.setDouble(
      _keyMaxDiscountAmount,
      settings.maxDiscountAmount,
    );
    await _datasource.setString(
      _keyDiscountPresets,
      _serializeDiscountPresets(settings.discountPresets),
    );
    await _datasource.setString(
      _keyActiveDiscountPresetId,
      settings.activeDiscountPresetId,
    );
    await _datasource.setString(_keyPromptpayId, settings.promptpayId);
    await _datasource.setString(_keyReceiptSize, settings.receiptSize);
    await _datasource.setInt(
      _keyBackupReminderDays,
      settings.backupReminderDays,
    );
    if (settings.lastBackupAt != null) {
      await _datasource.setString(_keyLastBackupAt, settings.lastBackupAt!);
    }
    await _datasource.setInt(_keyImageMaxWidth, settings.imageMaxWidth);
    await _datasource.setInt(_keyImageQuality, settings.imageQuality);
    await _datasource.setInt(_keyMaxDrafts, settings.maxDrafts);
    await _datasource.setBool(_keyCartCompactMode, settings.cartCompactMode);
    await _datasource.setBool(_keyUltraCompactMode, settings.ultraCompactMode);
  }

  Future<List<DiscountPreset>> _loadDiscountPresets() async {
    final jsonStr = await _datasource.getString(_keyDiscountPresets);
    if (jsonStr != null && jsonStr.trim().isNotEmpty) {
      try {
        final list = jsonDecode(jsonStr) as List;
        final presets = list
            .map(
              (e) => DiscountPreset(
                id: e['id'] as String? ?? '',
                name: e['name'] as String? ?? '',
                type: e['type'] as String? ?? 'PERCENT',
                values:
                    (e['values'] as List?)
                        ?.map((v) => (v as num).toDouble())
                        .toList() ??
                    const [5.0, 10.0, 20.0, 50.0],
              ),
            )
            .where((p) => p.id.isNotEmpty)
            .toList();
        if (presets.isNotEmpty) return presets;
      } catch (_) {
        // fall through to migration / default
      }
    }

    // Backward-compat: migrate old comma-separated presetDiscountValues
    final oldRaw = await _datasource.getString(_keyPresetDiscountValues);
    final values = _parseOldPresetValues(oldRaw);
    return [
      DiscountPreset(
        id: 'default',
        name: 'Default',
        type: 'PERCENT',
        values: values,
      ),
    ];
  }

  List<double> _parseOldPresetValues(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [5.0, 10.0, 20.0, 50.0];
    }
    final values = raw
        .split(',')
        .map((s) => double.tryParse(s.trim()))
        .whereType<double>()
        .where((v) => v > 0)
        .toList();
    return values.isNotEmpty ? values : const [5.0, 10.0, 20.0, 50.0];
  }

  String _serializeDiscountPresets(List<DiscountPreset> presets) {
    final list = presets
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'type': p.type,
            'values': p.values,
          },
        )
        .toList();
    return jsonEncode(list);
  }
}
