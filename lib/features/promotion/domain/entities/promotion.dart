import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

enum PromotionType { percent, amount }

class Promotion extends Equatable {
  const Promotion({
    required this.id,
    required this.name,
    this.type = PromotionType.percent,
    this.value = 0.0,
    this.minPurchaseAmount = Money.zero,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final PromotionType type;
  final double
  value; // Can be % or flat amount depending on [type] — stays double
  final Money minPurchaseAmount;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCurrentlyActive {
    final now = DateTime.now();
    if (!isActive) return false;
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// Returns the discount [Money] for a given [subtotal].
  /// Returns [Money.zero] if the promotion is not active or minimum
  /// purchase threshold is not met.
  Money discountFor(Money subtotal) {
    if (!isCurrentlyActive) return Money.zero;
    if (subtotal < minPurchaseAmount) return Money.zero;
    if (type == PromotionType.percent) {
      return subtotal * (value / 100);
    }
    // Flat amount — clamp to subtotal
    final disc = Money.fromDouble(value);
    return disc <= subtotal ? disc : subtotal;
  }

  Promotion copyWith({
    String? id,
    String? name,
    PromotionType? type,
    double? value,
    Money? minPurchaseAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Promotion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      minPurchaseAmount: minPurchaseAmount ?? this.minPurchaseAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    value,
    minPurchaseAmount,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
  ];
}
