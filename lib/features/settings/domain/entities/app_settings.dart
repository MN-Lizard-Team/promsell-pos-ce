import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';

const Object _unset = Object();

class AppSettings extends Equatable {
  const AppSettings({
    this.locale = const Locale('th'),
    this.themeMode = ThemeMode.system,
    this.shopName = '',
    this.address = '',
    this.phone = '',
    this.currency = '฿',
    this.dateFormat = 'dd/MM/yyyy',
    this.receiptNote = '',
    this.showShopInfoOnReceipt = true,
    this.autoPrintPrompt = true,
    this.vatRate = 7.0,
    this.vatMode = 'NONE',
    this.receiptPreviewStyle = 'thermal',
    this.showPreSalePreview = true,
    this.showPostSalePreview = true,
    this.allowOversell = false,
    this.lowStockThreshold = 5,
    this.enableItemDiscount = true,
    this.enableCartDiscount = true,
    this.maxDiscountPercent = 100.0,
    this.maxDiscountAmount = 0.0,
    this.defaultDiscountType = 'PERCENT',
    this.discountPresets = const [
      DiscountPreset(
        id: 'default',
        name: 'Default',
        type: 'PERCENT',
        values: [5.0, 10.0, 20.0, 50.0],
      ),
    ],
    this.activeDiscountPresetId = 'default',
    this.promptpayId = '',
    this.receiptSize = '80mm',
    this.backupReminderDays = 7,
    this.lastBackupAt,
    this.imageMaxWidth = 800,
    this.imageQuality = 80,
    this.maxDrafts = 30,
    this.cartCompactMode = false,
    this.ultraCompactMode = false,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final String shopName;
  final String address;
  final String phone;
  final String currency;
  final String dateFormat;
  final String receiptNote;
  final bool showShopInfoOnReceipt;
  final bool autoPrintPrompt;
  final double vatRate;
  final String vatMode;
  final String receiptPreviewStyle;
  final bool showPreSalePreview;
  final bool showPostSalePreview;
  final bool allowOversell;
  final int lowStockThreshold;
  final bool enableItemDiscount;
  final bool enableCartDiscount;
  final double maxDiscountPercent;
  final double maxDiscountAmount;
  final String defaultDiscountType;
  final List<DiscountPreset> discountPresets;
  final String activeDiscountPresetId;
  final String promptpayId;
  final String receiptSize;
  final int backupReminderDays;
  final String? lastBackupAt;
  final int imageMaxWidth;
  final int imageQuality;
  final int maxDrafts;
  final bool cartCompactMode;
  final bool ultraCompactMode;

  DiscountPreset get activeDiscountPreset {
    final match = discountPresets.where((p) => p.id == activeDiscountPresetId);
    return match.isNotEmpty ? match.first : discountPresets.first;
  }

  AppSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    String? shopName,
    String? address,
    String? phone,
    String? currency,
    String? dateFormat,
    String? receiptNote,
    bool? showShopInfoOnReceipt,
    bool? autoPrintPrompt,
    double? vatRate,
    String? vatMode,
    String? receiptPreviewStyle,
    bool? showPreSalePreview,
    bool? showPostSalePreview,
    bool? allowOversell,
    int? lowStockThreshold,
    bool? enableItemDiscount,
    bool? enableCartDiscount,
    double? maxDiscountPercent,
    double? maxDiscountAmount,
    String? defaultDiscountType,
    List<DiscountPreset>? discountPresets,
    String? activeDiscountPresetId,
    String? promptpayId,
    String? receiptSize,
    int? backupReminderDays,
    Object? lastBackupAt = _unset,
    int? imageMaxWidth,
    int? imageQuality,
    int? maxDrafts,
    bool? cartCompactMode,
    bool? ultraCompactMode,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      currency: currency ?? this.currency,
      dateFormat: dateFormat ?? this.dateFormat,
      receiptNote: receiptNote ?? this.receiptNote,
      showShopInfoOnReceipt:
          showShopInfoOnReceipt ?? this.showShopInfoOnReceipt,
      autoPrintPrompt: autoPrintPrompt ?? this.autoPrintPrompt,
      vatRate: vatRate ?? this.vatRate,
      vatMode: vatMode ?? this.vatMode,
      receiptPreviewStyle: receiptPreviewStyle ?? this.receiptPreviewStyle,
      showPreSalePreview: showPreSalePreview ?? this.showPreSalePreview,
      showPostSalePreview: showPostSalePreview ?? this.showPostSalePreview,
      allowOversell: allowOversell ?? this.allowOversell,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      enableItemDiscount: enableItemDiscount ?? this.enableItemDiscount,
      enableCartDiscount: enableCartDiscount ?? this.enableCartDiscount,
      maxDiscountPercent: maxDiscountPercent ?? this.maxDiscountPercent,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      defaultDiscountType: defaultDiscountType ?? this.defaultDiscountType,
      discountPresets: discountPresets ?? this.discountPresets,
      activeDiscountPresetId:
          activeDiscountPresetId ?? this.activeDiscountPresetId,
      promptpayId: promptpayId ?? this.promptpayId,
      receiptSize: receiptSize ?? this.receiptSize,
      backupReminderDays: backupReminderDays ?? this.backupReminderDays,
      lastBackupAt: identical(lastBackupAt, _unset)
          ? this.lastBackupAt
          : lastBackupAt as String?,
      imageMaxWidth: imageMaxWidth ?? this.imageMaxWidth,
      imageQuality: imageQuality ?? this.imageQuality,
      maxDrafts: maxDrafts ?? this.maxDrafts,
      cartCompactMode: cartCompactMode ?? this.cartCompactMode,
      ultraCompactMode: ultraCompactMode ?? this.ultraCompactMode,
    );
  }

  @override
  List<Object?> get props => [
    locale,
    themeMode,
    shopName,
    address,
    phone,
    currency,
    dateFormat,
    receiptNote,
    showShopInfoOnReceipt,
    autoPrintPrompt,
    vatRate,
    vatMode,
    receiptPreviewStyle,
    showPreSalePreview,
    showPostSalePreview,
    allowOversell,
    lowStockThreshold,
    enableItemDiscount,
    enableCartDiscount,
    maxDiscountPercent,
    maxDiscountAmount,
    defaultDiscountType,
    discountPresets,
    activeDiscountPresetId,
    promptpayId,
    receiptSize,
    backupReminderDays,
    lastBackupAt,
    imageMaxWidth,
    imageQuality,
    maxDrafts,
    cartCompactMode,
    ultraCompactMode,
  ];
}
