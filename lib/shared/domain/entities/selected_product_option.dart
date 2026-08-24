import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

/// A product option selected by the user during cart building or checkout.
///
/// Shared domain entity — used by sale, receipt, and product features.
/// Lives in `lib/shared/domain/` to avoid cross-feature domain coupling.
class SelectedProductOption extends Equatable {
  const SelectedProductOption({
    required this.optionId,
    required this.optionName,
    required this.groupId,
    required this.groupName,
    this.priceDelta = Money.zero,
  });

  final String optionId;
  final String optionName;
  final String groupId;
  final String groupName;
  final Money priceDelta;

  Money get totalPriceDelta => priceDelta;

  SelectedProductOption copyWith({
    String? optionId,
    String? optionName,
    String? groupId,
    String? groupName,
    Money? priceDelta,
  }) {
    return SelectedProductOption(
      optionId: optionId ?? this.optionId,
      optionName: optionName ?? this.optionName,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      priceDelta: priceDelta ?? this.priceDelta,
    );
  }

  Map<String, dynamic> toJson() => {
    'optionId': optionId,
    'optionName': optionName,
    'groupId': groupId,
    'groupName': groupName,
    'priceDelta': priceDelta.value,
  };

  factory SelectedProductOption.fromJson(Map<String, dynamic> json) =>
      SelectedProductOption(
        optionId: json['optionId'] as String,
        optionName: json['optionName'] as String? ?? '',
        groupId: json['groupId'] as String? ?? '',
        groupName: json['groupName'] as String? ?? '',
        priceDelta: Money.fromDouble(
          (json['priceDelta'] as num?)?.toDouble() ?? 0.0,
        ),
      );

  @override
  List<Object?> get props => [
    optionId,
    optionName,
    groupId,
    groupName,
    priceDelta,
  ];
}
