import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

class MockSettingsLocalDatasource extends Mock
    implements SettingsLocalDatasource {}

void main() {
  group('SettingsRepositoryImpl', () {
    late MockSettingsLocalDatasource mockDatasource;
    late SettingsRepositoryImpl repo;

    setUp(() {
      mockDatasource = MockSettingsLocalDatasource();
      repo = SettingsRepositoryImpl(mockDatasource);
    });

    test('load returns defaults when datasource is empty', () async {
      when(() => mockDatasource.getString(any())).thenAnswer((_) async => null);
      when(() => mockDatasource.getInt(any())).thenAnswer((_) async => null);
      when(() => mockDatasource.getBool(any())).thenAnswer((_) async => null);
      when(() => mockDatasource.getDouble(any())).thenAnswer((_) async => null);

      final settings = await repo.load();

      expect(settings.locale, const Locale('th'));
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.shopName, '');
      expect(settings.currency, '฿');
      expect(settings.showShopInfoOnReceipt, isTrue);
      expect(settings.autoPrintPrompt, isTrue);
      expect(settings.vatRate, 7.0);
      expect(settings.vatMode, 'NONE');
      expect(settings.receiptPreviewStyle, 'thermal');
      expect(settings.showPreSalePreview, isTrue);
      expect(settings.showPostSalePreview, isTrue);
    });

    test('load returns saved values from datasource', () async {
      when(
        () => mockDatasource.getString('locale'),
      ).thenAnswer((_) async => 'en');
      when(
        () => mockDatasource.getInt('theme'),
      ).thenAnswer((_) async => ThemeMode.dark.index);
      when(
        () => mockDatasource.getString('shopName'),
      ).thenAnswer((_) async => 'My Shop');
      when(
        () => mockDatasource.getString('currency'),
      ).thenAnswer((_) async => '\$');
      when(
        () => mockDatasource.getBool('showShopInfo'),
      ).thenAnswer((_) async => false);
      when(
        () => mockDatasource.getString(
          any(
            that: isNot(
              isIn(['locale', 'theme', 'shopName', 'currency', 'showShopInfo']),
            ),
          ),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => mockDatasource.getInt(any(that: isNot(equals('theme')))),
      ).thenAnswer((_) async => null);
      when(
        () => mockDatasource.getBool(any(that: isNot(equals('showShopInfo')))),
      ).thenAnswer((_) async => null);
      when(() => mockDatasource.getDouble(any())).thenAnswer((_) async => null);

      final settings = await repo.load();

      expect(settings.locale, const Locale('en'));
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.shopName, 'My Shop');
      expect(settings.currency, '\$');
      expect(settings.showShopInfoOnReceipt, isFalse);
      expect(settings.autoPrintPrompt, isTrue);
      expect(settings.vatRate, 7.0);
      expect(settings.vatMode, 'NONE');
      expect(settings.receiptPreviewStyle, 'thermal');
      expect(settings.showPreSalePreview, isTrue);
      expect(settings.showPostSalePreview, isTrue);
    });

    test('save persists all settings to datasource', () async {
      when(
        () => mockDatasource.setString(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockDatasource.setInt(any(), any())).thenAnswer((_) async {});
      when(() => mockDatasource.setBool(any(), any())).thenAnswer((_) async {});
      when(
        () => mockDatasource.setDouble(any(), any()),
      ).thenAnswer((_) async {});

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
        autoPrintPrompt: false,
        vatRate: 10.0,
        vatMode: 'INCLUSIVE',
        receiptPreviewStyle: 'card',
        showPreSalePreview: false,
        showPostSalePreview: false,
      );

      await repo.save(settings);

      verify(() => mockDatasource.setString('locale', 'en')).called(1);
      verify(
        () => mockDatasource.setInt('theme', ThemeMode.light.index),
      ).called(1);
      verify(() => mockDatasource.setString('shopName', 'Test Shop')).called(1);
      verify(() => mockDatasource.setString('address', '123 Street')).called(1);
      verify(() => mockDatasource.setString('phone', '0812345678')).called(1);
      verify(() => mockDatasource.setString('currency', '\$')).called(1);
      verify(
        () => mockDatasource.setString('dateFormat', 'yyyy-MM-dd'),
      ).called(1);
      verify(
        () => mockDatasource.setString('receiptNote', 'Thank you!'),
      ).called(1);
      verify(() => mockDatasource.setBool('showShopInfo', false)).called(1);
      verify(() => mockDatasource.setBool('autoPrintPrompt', false)).called(1);
      verify(() => mockDatasource.setDouble('vatRate', 10.0)).called(1);
      verify(() => mockDatasource.setString('vatMode', 'INCLUSIVE')).called(1);
      verify(
        () => mockDatasource.setString('receiptPreviewStyle', 'card'),
      ).called(1);
      verify(
        () => mockDatasource.setBool('showPreSalePreview', false),
      ).called(1);
      verify(
        () => mockDatasource.setBool('showPostSalePreview', false),
      ).called(1);
    });

    test('load handles invalid theme index gracefully', () async {
      when(() => mockDatasource.getString(any())).thenAnswer((_) async => null);
      when(() => mockDatasource.getInt('theme')).thenAnswer((_) async => 999);
      when(() => mockDatasource.getBool(any())).thenAnswer((_) async => null);
      when(() => mockDatasource.getDouble(any())).thenAnswer((_) async => null);

      final settings = await repo.load();

      expect(settings.themeMode, ThemeMode.system);
    });
  });
}
