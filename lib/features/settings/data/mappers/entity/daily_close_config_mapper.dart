import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/daily_close_config.dart';

class DailyCloseConfigMapper {
  Map<String, String> toMap(DailyCloseConfig dailyClose) {
    return {
      SettingsMapperKeys.keyDailyCloseLock: dailyClose.dailyCloseLock
          .toString(),
      SettingsMapperKeys.keyLastClosedDate: dailyClose.lastClosedDate ?? '',
    };
  }

  DailyCloseConfig fromMap(Map<String, String> map) {
    return DailyCloseConfig(
      dailyCloseLock: parseBool(
        map[SettingsMapperKeys.keyDailyCloseLock],
        false,
      ),
      lastClosedDate: nullIfEmpty(map[SettingsMapperKeys.keyLastClosedDate]),
    );
  }
}
