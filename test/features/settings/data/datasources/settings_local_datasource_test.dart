import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late SettingsLocalDatasourceImpl datasource;

  setUp(() {
    db = createInMemoryDatabase();
    datasource = SettingsLocalDatasourceImpl(db);
  });

  tearDown(() => db.close());

  group('getString / setString', () {
    test('returns null for missing key', () async {
      expect(await datasource.getString('nonexistent'), isNull);
    });

    test('writes and reads a string', () async {
      await datasource.setString('shop_name', 'Test Shop');
      expect(await datasource.getString('shop_name'), 'Test Shop');
    });

    test('overwrites existing key', () async {
      await datasource.setString('shop_name', 'Old');
      await datasource.setString('shop_name', 'New');
      expect(await datasource.getString('shop_name'), 'New');
    });
  });

  group('getInt / setInt', () {
    test('returns null for missing key', () async {
      expect(await datasource.getInt('seq'), isNull);
    });

    test('writes and reads an int', () async {
      await datasource.setInt('seq', 42);
      expect(await datasource.getInt('seq'), 42);
    });

    test('returns null for non-numeric string', () async {
      await datasource.setString('bad', 'abc');
      expect(await datasource.getInt('bad'), isNull);
    });
  });

  group('getBool / setBool', () {
    test('returns null for missing key', () async {
      expect(await datasource.getBool('flag'), isNull);
    });

    test('writes true and reads it', () async {
      await datasource.setBool('flag', true);
      expect(await datasource.getBool('flag'), isTrue);
    });

    test('writes false and reads it', () async {
      await datasource.setBool('flag', false);
      expect(await datasource.getBool('flag'), isFalse);
    });
  });

  group('getDouble / setDouble', () {
    test('returns null for missing key', () async {
      expect(await datasource.getDouble('rate'), isNull);
    });

    test('writes and reads a double', () async {
      await datasource.setDouble('rate', 7.5);
      expect(await datasource.getDouble('rate'), 7.5);
    });
  });

  group('getAll', () {
    test('returns seeded defaults', () async {
      final all = await datasource.getAll();
      expect(all, containsPair('shop_name', ''));
      expect(all, containsPair('vat_rate', '7'));
      expect(all, containsPair('vat_mode', 'NONE'));
      expect(all, containsPair('currency_symbol', '฿'));
      expect(all, containsPair('receipt_footer', ''));
    });

    test('includes custom keys', () async {
      await datasource.setString('custom_key', 'hello');
      final all = await datasource.getAll();
      expect(all, containsPair('custom_key', 'hello'));
    });
  });
}
