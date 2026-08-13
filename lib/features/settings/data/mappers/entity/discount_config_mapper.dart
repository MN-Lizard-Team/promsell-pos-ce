import 'dart:convert';

import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/entity/mapper_helpers.dart';
import 'package:promsell_pos_ce/features/settings/data/mappers/settings_mapper_keys.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';

class DiscountConfigMapper {
  Map<String, String> toMap(DiscountConfig discount) {
    return {
      SettingsMapperKeys.keyEnableItemDiscount: discount.enableItemDiscount
          .toString(),
      SettingsMapperKeys.keyEnableCartDiscount: discount.enableCartDiscount
          .toString(),
      SettingsMapperKeys.keyMaxDiscountPercent: discount.maxDiscountPercent
          .toString(),
      SettingsMapperKeys.keyMaxDiscountAmount: discount.maxDiscountAmount.value
          .toString(),
      SettingsMapperKeys.keyDefaultDiscountType: discount.defaultDiscountType,
      SettingsMapperKeys.keyDiscountPresets: _serializeDiscountPresets(
        discount.discountPresets,
      ),
      SettingsMapperKeys.keyActiveDiscountPresetId:
          discount.activeDiscountPresetId,
    };
  }

  DiscountConfig fromMap(Map<String, String> map) {
    return DiscountConfig(
      enableItemDiscount: parseBool(
        map[SettingsMapperKeys.keyEnableItemDiscount],
        true,
      ),
      enableCartDiscount: parseBool(
        map[SettingsMapperKeys.keyEnableCartDiscount],
        true,
      ),
      maxDiscountPercent: parseDouble(
        map[SettingsMapperKeys.keyMaxDiscountPercent],
        100.0,
      ),
      maxDiscountAmount: Money.fromDouble(
        parseDouble(map[SettingsMapperKeys.keyMaxDiscountAmount], 0.0),
      ),
      defaultDiscountType:
          map[SettingsMapperKeys.keyDefaultDiscountType] ?? 'PERCENT',
      discountPresets: _parseDiscountPresets(
        map[SettingsMapperKeys.keyDiscountPresets],
      ),
      activeDiscountPresetId:
          map[SettingsMapperKeys.keyActiveDiscountPresetId] ?? 'default',
    );
  }

  String _serializeDiscountPresets(List<DiscountPreset> presets) {
    final list = presets
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'type': p.type,
            'values': p.values,
          },
        )
        .toList();
    return jsonEncode(list);
  }

  List<DiscountPreset> _parseDiscountPresets(String? raw) {
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        final presets = list
            .map(
              (e) => DiscountPreset(
                id: e['id'] as String? ?? '',
                name: e['name'] as String? ?? '',
                type: e['type'] as String? ?? 'PERCENT',
                values:
                    (e['values'] as List?)
                        ?.map((v) => (v as num).toDouble())
                        .toList() ??
                    const [5.0, 10.0, 20.0, 50.0],
              ),
            )
            .where((p) => p.id.isNotEmpty)
            .toList();
        if (presets.isNotEmpty) return presets;
      } catch (e, stack) {
        AppLogger.warning(
          'DiscountConfigMapper: discount presets parse failed',
          error: e,
          stack: stack,
        );
      }
    }
    return const [
      DiscountPreset(
        id: 'default',
        name: 'Default',
        type: 'PERCENT',
        values: [5.0, 10.0, 20.0, 50.0],
      ),
    ];
  }
}
