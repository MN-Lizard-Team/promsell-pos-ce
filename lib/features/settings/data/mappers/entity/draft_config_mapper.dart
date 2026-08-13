import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/draft_config.dart';

class DraftConfigMapper {
  Map<String, String> toMap(DraftConfig draft) {
    return {SettingsMapperKeys.keyMaxDrafts: draft.maxDrafts.toString()};
  }

  DraftConfig fromMap(Map<String, String> map) {
    return DraftConfig(
      maxDrafts: parseInt(map[SettingsMapperKeys.keyMaxDrafts], 30),
    );
  }
}
