import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

void main() {
  group('BusinessConfig', () {
    test('default businessType is retail', () {
      const settings = Settings();
      expect(settings.businessType, BusinessType.retail);
    });

    test('default isRestaurantMode is false', () {
      const settings = Settings();
      expect(settings.isRestaurantMode, isFalse);
    });

    test('default defaultServiceChargeRate is 0', () {
      const settings = Settings();
      expect(settings.defaultServiceChargeRate, 0.0);
    });
  });

  group('Settings.copyWith business fields', () {
    test('updates businessType to restaurant', () {
      const settings = Settings();
      final updated = settings.copyWith(businessType: BusinessType.restaurant);
      expect(updated.businessType, BusinessType.restaurant);
      expect(updated.isRestaurantMode, isTrue);
    });

    test('updates defaultServiceChargeRate', () {
      const settings = Settings();
      final updated = settings.copyWith(defaultServiceChargeRate: 10.0);
      expect(updated.defaultServiceChargeRate, 10.0);
    });

    test('preserves businessType when updating other fields', () {
      const settings = Settings(
        businessConfig: BusinessConfig(
          businessType: BusinessType.restaurant,
          defaultServiceChargeRate: 7.0,
        ),
      );
      final updated = settings.copyWith(shopName: 'My Restaurant');
      expect(updated.businessType, BusinessType.restaurant);
      expect(updated.defaultServiceChargeRate, 7.0);
      expect(updated.shopName, 'My Restaurant');
    });
  });
}
