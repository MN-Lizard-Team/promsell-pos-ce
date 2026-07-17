import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option.dart';

enum OptionSelectionType { single, multiple }

class ProductOptionGroup extends Equatable {
  const ProductOptionGroup({
    required this.id,
    required this.productId,
    required this.name,
    this.selectionType = OptionSelectionType.single,
    this.isRequired = false,
    this.sortOrder = 0,
    this.options = const [],
  });

  final String id;
  final String productId;
  final String name;
  final OptionSelectionType selectionType;
  final bool isRequired;
  final int sortOrder;
  final List<ProductOption> options;

  ProductOptionGroup copyWith({
    String? id,
    String? productId,
    String? name,
    OptionSelectionType? selectionType,
    bool? isRequired,
    int? sortOrder,
    List<ProductOption>? options,
  }) {
    return ProductOptionGroup(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      selectionType: selectionType ?? this.selectionType,
      isRequired: isRequired ?? this.isRequired,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'name': name,
    'selectionType': selectionType.name,
    'isRequired': isRequired,
    'sortOrder': sortOrder,
    'options': options.map((option) => option.toJson()).toList(),
  };

  factory ProductOptionGroup.fromJson(Map<String, dynamic> json) {
    final optionValues = json['options'] as List<dynamic>? ?? const [];
    return ProductOptionGroup(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      selectionType: json['selectionType'] == OptionSelectionType.multiple.name
          ? OptionSelectionType.multiple
          : OptionSelectionType.single,
      isRequired: json['isRequired'] as bool? ?? false,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      options: optionValues
          .whereType<Map<String, dynamic>>()
          .map(ProductOption.fromJson)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    name,
    selectionType,
    isRequired,
    sortOrder,
    options,
  ];
}
