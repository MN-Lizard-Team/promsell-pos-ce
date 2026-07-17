import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

class CartItem extends Equatable {
  CartItem({
    required this.product,
    required this.qty,
    this.discountType,
    this.discountValue, // Raw value — can be % or flat amount
    this.note,
    this.selectedOptions = const [],
    this.isAvailable = true,
    String? lineId,
  }) : lineId = lineId ?? IdGenerator.newId();

  final String lineId;
  final Product product;
  final int qty;
  final String? discountType;
  final double? discountValue;
  final String? note;
  final List<SelectedProductOption> selectedOptions;
  final bool isAvailable;

  Money get _optionsPriceDelta =>
      selectedOptions.fold(Money.zero, (sum, o) => sum + o.priceDelta);

  Money get rawSubtotal => (product.price + _optionsPriceDelta) * qty;

  Money get discountAmount {
    if (discountType == null || discountValue == null || discountValue! <= 0) {
      return Money.zero;
    }
    if (discountType == 'PERCENT') {
      return rawSubtotal * (discountValue! / 100);
    }
    // Flat amount — clamp to rawSubtotal
    final disc = Money.fromDouble(discountValue!);
    return disc <= rawSubtotal ? disc : rawSubtotal;
  }

  Money get subtotal => rawSubtotal - discountAmount;

  CartItem copyWith({
    Product? product,
    int? qty,
    Object? discountType = _unset,
    Object? discountValue = _unset,
    Object? note = _unset,
    List<SelectedProductOption>? selectedOptions,
    bool? isAvailable,
  }) => CartItem(
    product: product ?? this.product,
    qty: qty ?? this.qty,
    lineId: lineId,
    discountType: identical(discountType, _unset)
        ? this.discountType
        : discountType as String?,
    discountValue: identical(discountValue, _unset)
        ? this.discountValue
        : discountValue as double?,
    note: identical(note, _unset) ? this.note : note as String?,
    selectedOptions: selectedOptions ?? this.selectedOptions,
    isAvailable: isAvailable ?? this.isAvailable,
  );

  CartItem clearDiscount() => CartItem(
    product: product,
    qty: qty,
    note: note,
    lineId: lineId,
    selectedOptions: selectedOptions,
    isAvailable: isAvailable,
  );

  @override
  List<Object?> get props => [
    lineId,
    product,
    qty,
    discountType,
    discountValue,
    note,
    selectedOptions,
    isAvailable,
  ];
}

const Object _unset = Object();
