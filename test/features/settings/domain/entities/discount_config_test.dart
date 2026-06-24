import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';

void main() {
  group('DiscountPreset', () {
    test('has default values', () {
      const preset = DiscountPreset(id: 'p1', name: 'Custom');
      expect(preset.type, 'PERCENT');
      expect(preset.values, [5.0, 10.0, 20.0, 50.0]);
    });

    test('copyWith updates fields', () {
      const preset = DiscountPreset(id: 'p1', name: 'Custom');
      final updated = preset.copyWith(name: 'Updated', type: 'AMOUNT');
      expect(updated.name, 'Updated');
      expect(updated.type, 'AMOUNT');
      expect(updated.id, 'p1');
    });

    test('supports value equality', () {
      const a = DiscountPreset(id: 'p1', name: 'Test');
      const b = DiscountPreset(id: 'p1', name: 'Test');
      expect(a, equals(b));
    });
  });

  group('DiscountConfig', () {
    test('has default values', () {
      const config = DiscountConfig();
      expect(config.enableItemDiscount, isTrue);
      expect(config.enableCartDiscount, isTrue);
      expect(config.maxDiscountPercent, 100.0);
      expect(config.defaultDiscountType, 'PERCENT');
    });

    test('activeDiscountPreset returns matching preset', () {
      const config = DiscountConfig(
        discountPresets: [
          DiscountPreset(id: 'p1', name: 'A'),
          DiscountPreset(id: 'p2', name: 'B'),
        ],
        activeDiscountPresetId: 'p2',
      );
      expect(config.activeDiscountPreset.name, 'B');
    });

    test('activeDiscountPreset returns first when id not found', () {
      const config = DiscountConfig(
        discountPresets: [
          DiscountPreset(id: 'p1', name: 'A'),
          DiscountPreset(id: 'p2', name: 'B'),
        ],
        activeDiscountPresetId: 'nonexistent',
      );
      expect(config.activeDiscountPreset.name, 'A');
    });

    test('activeDiscountPreset returns default when presets empty', () {
      const config = DiscountConfig(
        discountPresets: [],
        activeDiscountPresetId: 'default',
      );
      expect(config.activeDiscountPreset.id, 'default');
    });

    test('copyWith updates fields', () {
      const config = DiscountConfig();
      final updated = config.copyWith(
        enableItemDiscount: false,
        maxDiscountPercent: 50.0,
      );
      expect(updated.enableItemDiscount, isFalse);
      expect(updated.maxDiscountPercent, 50.0);
      expect(updated.enableCartDiscount, isTrue);
    });
  });
}
