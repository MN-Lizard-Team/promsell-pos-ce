import 'package:equatable/equatable.dart';

class SelectedProductOption extends Equatable {
  const SelectedProductOption({
    required this.optionId,
    required this.optionName,
    required this.groupId,
    required this.groupName,
    this.priceDelta = 0.0,
  });

  final String optionId;
  final String optionName;
  final String groupId;
  final String groupName;
  final double priceDelta;

  double get totalPriceDelta => priceDelta;

  SelectedProductOption copyWith({
    String? optionId,
    String? optionName,
    String? groupId,
    String? groupName,
    double? priceDelta,
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
    'priceDelta': priceDelta,
  };

  factory SelectedProductOption.fromJson(Map<String, dynamic> json) =>
      SelectedProductOption(
        optionId: json['optionId'] as String,
        optionName: json['optionName'] as String? ?? '',
        groupId: json['groupId'] as String? ?? '',
        groupName: json['groupName'] as String? ?? '',
        priceDelta: (json['priceDelta'] as num?)?.toDouble() ?? 0.0,
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
