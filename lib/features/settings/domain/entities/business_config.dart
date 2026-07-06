import 'package:equatable/equatable.dart';

enum BusinessType { retail, restaurant }

class BusinessConfig extends Equatable {
  const BusinessConfig({
    this.businessType = BusinessType.retail,
    this.defaultServiceChargeRate = 0.0,
  });

  final BusinessType businessType;
  final double defaultServiceChargeRate;

  bool get isRestaurant => businessType == BusinessType.restaurant;

  BusinessConfig copyWith({
    BusinessType? businessType,
    double? defaultServiceChargeRate,
  }) {
    return BusinessConfig(
      businessType: businessType ?? this.businessType,
      defaultServiceChargeRate:
          defaultServiceChargeRate ?? this.defaultServiceChargeRate,
    );
  }

  @override
  List<Object?> get props => [businessType, defaultServiceChargeRate];
}
