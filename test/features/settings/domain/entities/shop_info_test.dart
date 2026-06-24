import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/daily_close_config.dart';

void main() {
  group('ShopInfo', () {
    test('has default empty values', () {
      const info = ShopInfo();
      expect(info.name, '');
      expect(info.address, '');
      expect(info.phone, '');
    });

    test('isComplete is false when name is empty', () {
      const info = ShopInfo(phone: '0812345678');
      expect(info.isComplete, isFalse);
    });

    test('isComplete is false when phone is empty', () {
      const info = ShopInfo(name: 'My Shop');
      expect(info.isComplete, isFalse);
    });

    test('isComplete is true when name and phone are set', () {
      const info = ShopInfo(name: 'My Shop', phone: '0812345678');
      expect(info.isComplete, isTrue);
    });

    test('copyWith updates fields', () {
      const info = ShopInfo();
      final updated = info.copyWith(name: 'Shop', address: '123 St');
      expect(updated.name, 'Shop');
      expect(updated.address, '123 St');
    });
  });

  group('BackupConfig', () {
    test('has default values', () {
      const config = BackupConfig();
      expect(config.reminderDays, 7);
      expect(config.encryptionEnabled, isFalse);
    });

    test('copyWith updates fields', () {
      const config = BackupConfig();
      final updated = config.copyWith(
        reminderDays: 30,
        encryptionEnabled: true,
      );
      expect(updated.reminderDays, 30);
      expect(updated.encryptionEnabled, isTrue);
    });

    test('isOverdue is false when reminderDays is 0', () {
      const config = BackupConfig(reminderDays: 0);
      expect(config.isOverdue, isFalse);
    });

    test('isOverdue is true when lastBackupAt is null', () {
      const config = BackupConfig(reminderDays: 7);
      expect(config.isOverdue, isTrue);
    });

    test('isOverdue is true when lastBackupAt is empty', () {
      const config = BackupConfig(reminderDays: 7, lastBackupAt: '');
      expect(config.isOverdue, isTrue);
    });

    test('isOverdue is true when lastBackupAt is invalid', () {
      const config = BackupConfig(reminderDays: 7, lastBackupAt: 'invalid');
      expect(config.isOverdue, isTrue);
    });

    test('isOverdue is false when backup is recent', () {
      final recent = DateTime.now().toIso8601String();
      final config = BackupConfig(reminderDays: 7, lastBackupAt: recent);
      expect(config.isOverdue, isFalse);
    });
  });

  group('DeviceConfig', () {
    test('has default values', () {
      const config = DeviceConfig();
      expect(config.deviceId, '');
      expect(config.devicePrefix, '');
      expect(config.isConfigured, isFalse);
    });

    test('isConfigured is true when both fields set', () {
      const config = DeviceConfig(deviceId: 'dev1', devicePrefix: 'POS01');
      expect(config.isConfigured, isTrue);
    });

    test('copyWith updates fields', () {
      const config = DeviceConfig();
      final updated = config.copyWith(devicePrefix: 'POS01');
      expect(updated.devicePrefix, 'POS01');
    });
  });

  group('DailyCloseConfig', () {
    test('has default values', () {
      const config = DailyCloseConfig();
      expect(config.dailyCloseLock, isFalse);
      expect(config.lastClosedDate, isNull);
    });

    test('copyWith updates fields', () {
      const config = DailyCloseConfig();
      final updated = config.copyWith(
        dailyCloseLock: true,
        lastClosedDate: '2024-01-01',
      );
      expect(updated.dailyCloseLock, isTrue);
      expect(updated.lastClosedDate, '2024-01-01');
    });
  });
}
