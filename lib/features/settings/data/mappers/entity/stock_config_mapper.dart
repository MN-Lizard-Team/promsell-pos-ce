import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';

class StockConfigMapper {
  Map<String, String> toMap(StockConfig stock) {
    return {
      SettingsMapperKeys.keyAllowOversell: stock.allowOversell.toString(),
      SettingsMapperKeys.keyLowStockThreshold: stock.lowStockThreshold
          .toString(),
    };
  }

  StockConfig fromMap(Map<String, String> map) {
    return StockConfig(
      allowOversell: parseBool(map[SettingsMapperKeys.keyAllowOversell], false),
      lowStockThreshold: parseInt(
        map[SettingsMapperKeys.keyLowStockThreshold],
        5,
      ),
    );
  }
}
