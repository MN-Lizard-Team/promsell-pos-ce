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
