import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/image_config.dart';

class ImageConfigMapper {
  Map<String, String> toMap(ImageConfig image) {
    return {
      SettingsMapperKeys.keyImageMaxWidth: image.maxWidth.toString(),
      SettingsMapperKeys.keyImageQuality: image.quality.toString(),
    };
  }

  ImageConfig fromMap(Map<String, String> map) {
    return ImageConfig(
      maxWidth: parseInt(map[SettingsMapperKeys.keyImageMaxWidth], 800),
      quality: parseInt(map[SettingsMapperKeys.keyImageQuality], 80),
    );
  }
}
