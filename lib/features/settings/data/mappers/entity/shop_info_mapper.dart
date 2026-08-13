import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';

class ShopInfoMapper {
  Map<String, String> toMap(ShopInfo shop) {
    return {
      SettingsMapperKeys.keyShopName: shop.name,
      SettingsMapperKeys.keyAddress: shop.address,
      SettingsMapperKeys.keyPhone: shop.phone,
      SettingsMapperKeys.keyTaxId: shop.taxId,
    };
  }

  ShopInfo fromMap(Map<String, String> map) {
    return ShopInfo(
      name: parseString(
        map,
        SettingsMapperKeys.keyShopName,
        legacy: SettingsMapperKeys.legacyShopName,
      ),
      address: map[SettingsMapperKeys.keyAddress] ?? '',
      phone: map[SettingsMapperKeys.keyPhone] ?? '',
      taxId: map[SettingsMapperKeys.keyTaxId] ?? '',
    );
  }
}
