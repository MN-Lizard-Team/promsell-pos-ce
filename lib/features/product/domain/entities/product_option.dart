import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

class ProductOption extends Equatable {
  const ProductOption({
    required this.id,
    required this.groupId,
    required this.name,
    this.priceDelta = Money.zero,
    this.sortOrder = 0,
  });

  final String id;
  final String groupId;
  final String name;
  final Money priceDelta;
  final int sortOrder;

  ProductOption copyWith({
    String? id,
    String? groupId,
    String? name,
    Money? priceDelta,
    int? sortOrder,
  }) {
    return ProductOption(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      priceDelta: priceDelta ?? this.priceDelta,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'groupId': groupId,
    'name': name,
    'priceDelta': priceDelta.value,
    'sortOrder': sortOrder,
  };

  factory ProductOption.fromJson(Map<String, dynamic> json) {
    final priceDeltaValue = (json['priceDelta'] as num?)?.toDouble() ?? 0.0;
    // Validate that priceDelta has at most 2 decimal places (satang precision).
    if ((priceDeltaValue * 100).roundToDouble() / 100 != priceDeltaValue) {
      throw ArgumentError(
        'priceDelta must have at most 2 decimal places, got: $priceDeltaValue',
      );
    }
    return ProductOption(
      id: json['id'] as String,
      groupId: json['groupId'] as String? ?? '',
      name: json['name'] as String,
      priceDelta: Money.fromDouble(priceDeltaValue),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, groupId, name, priceDelta, sortOrder];
}
