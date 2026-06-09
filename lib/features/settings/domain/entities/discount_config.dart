import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';

class DiscountConfig extends Equatable {
  const DiscountConfig({
    this.enableItemDiscount = true,
    this.enableCartDiscount = true,
    this.maxDiscountPercent = 100.0,
    this.maxDiscountAmount = 0.0,
    this.defaultDiscountType = 'PERCENT',
    this.discountPresets = const [
      DiscountPreset(
        id: 'default',
        name: 'Default',
        type: 'PERCENT',
        values: [5.0, 10.0, 20.0, 50.0],
      ),
    ],
    this.activeDiscountPresetId = 'default',
  });

  final bool enableItemDiscount;
  final bool enableCartDiscount;
  final double maxDiscountPercent;
  final double maxDiscountAmount;
  final String defaultDiscountType;
  final List<DiscountPreset> discountPresets;
  final String activeDiscountPresetId;

  DiscountPreset get activeDiscountPreset {
    if (discountPresets.isEmpty) {
      return const DiscountPreset(
        id: 'default',
        name: 'Default',
        type: 'PERCENT',
        values: [5.0, 10.0, 20.0, 50.0],
      );
    }
    final match = discountPresets.where((p) => p.id == activeDiscountPresetId);
    return match.isNotEmpty ? match.first : discountPresets.first;
  }

  DiscountConfig copyWith({
    bool? enableItemDiscount,
    bool? enableCartDiscount,
    double? maxDiscountPercent,
    double? maxDiscountAmount,
    String? defaultDiscountType,
    List<DiscountPreset>? discountPresets,
    String? activeDiscountPresetId,
  }) {
    return DiscountConfig(
      enableItemDiscount: enableItemDiscount ?? this.enableItemDiscount,
      enableCartDiscount: enableCartDiscount ?? this.enableCartDiscount,
      maxDiscountPercent: maxDiscountPercent ?? this.maxDiscountPercent,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      defaultDiscountType: defaultDiscountType ?? this.defaultDiscountType,
      discountPresets: discountPresets ?? this.discountPresets,
      activeDiscountPresetId:
          activeDiscountPresetId ?? this.activeDiscountPresetId,
    );
  }

  @override
  List<Object?> get props => [
    enableItemDiscount,
    enableCartDiscount,
    maxDiscountPercent,
    maxDiscountAmount,
    defaultDiscountType,
    discountPresets,
    activeDiscountPresetId,
  ];
}
