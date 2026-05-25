import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

const Object _unset = Object();

enum SaleStatus { idle, processing, success, failure }

class SaleState extends Equatable {
  const SaleState({
    this.status = SaleStatus.idle,
    this.items = const [],
    this.note = '',
    this.lastSale,
    this.errorMessage,
  });

  final SaleStatus status;
  final List<CartItem> items;
  final String note;
  final Sale? lastSale;
  final String? errorMessage;

  double get total => double.parse(
      items.fold(0.0, (sum, i) => sum + i.subtotal).toStringAsFixed(2));
  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold(0, (sum, i) => sum + i.qty);

  SaleState copyWith({
    SaleStatus? status,
    List<CartItem>? items,
    String? note,
    Object? lastSale = _unset,
    Object? errorMessage = _unset,
  }) =>
      SaleState(
        status: status ?? this.status,
        items: items ?? this.items,
        note: note ?? this.note,
        lastSale: identical(lastSale, _unset) ? this.lastSale : lastSale as Sale?,
        errorMessage: identical(errorMessage, _unset)
            ? this.errorMessage
            : errorMessage as String?,
      );

  @override
  List<Object?> get props =>
      [status, items, note, lastSale, errorMessage];
}
