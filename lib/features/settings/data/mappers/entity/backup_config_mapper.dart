import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';

class BackupConfigMapper {
  Map<String, String> toMap(BackupConfig backup) {
    return {
      SettingsMapperKeys.keyBackupReminderDays: backup.reminderDays.toString(),
      SettingsMapperKeys.keyLastBackupAt: backup.lastBackupAt ?? '',
      SettingsMapperKeys.keyBackupEncryptionEnabled: backup.encryptionEnabled
          .toString(),
    };
  }

  BackupConfig fromMap(Map<String, String> map) {
    return BackupConfig(
      reminderDays: parseInt(map[SettingsMapperKeys.keyBackupReminderDays], 7),
      lastBackupAt: nullIfEmpty(map[SettingsMapperKeys.keyLastBackupAt]),
      // Default on (v0.9): matches BackupConfig entity; stored value wins if key exists.
      encryptionEnabled: parseBool(
        map[SettingsMapperKeys.keyBackupEncryptionEnabled],
        true,
      ),
    );
  }
}
