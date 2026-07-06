import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/selected_product_option.dart';

class CartItem extends Equatable {
  CartItem({
    required this.product,
    required this.qty,
    this.discountType,
    this.discountValue,
    this.note,
    this.selectedOptions = const [],
    String? lineId,
  }) : lineId = lineId ?? IdGenerator.newId();

  final String lineId;
  final Product product;
  final int qty;
  final String? discountType;
  final double? discountValue;
  final String? note;
  final List<SelectedProductOption> selectedOptions;

  double get rawSubtotal =>
      MoneyUtils.round((product.price + _optionsPriceDelta) * qty);

  double get _optionsPriceDelta =>
      selectedOptions.fold(0.0, (sum, o) => sum + o.priceDelta);

  double get discountAmount {
    if (discountType == null || discountValue == null || discountValue! <= 0) {
      return 0.0;
    }
    if (discountType == 'PERCENT') {
      return MoneyUtils.round(rawSubtotal * (discountValue! / 100));
    }
    return MoneyUtils.round(discountValue!.clamp(0.0, rawSubtotal));
  }

  double get subtotal => MoneyUtils.round(rawSubtotal - discountAmount);

  CartItem copyWith({
    Product? product,
    int? qty,
    Object? discountType = _unset,
    Object? discountValue = _unset,
    Object? note = _unset,
    List<SelectedProductOption>? selectedOptions,
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
  );

  CartItem clearDiscount() => CartItem(
    product: product,
    qty: qty,
    note: note,
    lineId: lineId,
    selectedOptions: selectedOptions,
  );

  @override
  List<Object?> get props => [
    product,
    qty,
    discountType,
    discountValue,
    note,
    selectedOptions,
  ];
}

const Object _unset = Object();
