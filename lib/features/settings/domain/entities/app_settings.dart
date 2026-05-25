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
      ];
}
