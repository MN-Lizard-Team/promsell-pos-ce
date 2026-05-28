import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
  ];
}
