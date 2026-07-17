import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

const Object _unset = Object();

enum CheckoutStatus { idle, processing, waitingPayment, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.lastSale,
    this.errorMessage,
    this.promptPayAmount,
    this.frozenItems,
  });

  final CheckoutStatus status;
  final Sale? lastSale;
  final String? errorMessage;

  /// Amount to show on PromptPay QR (full bill or PP tender share).
  final double? promptPayAmount;

  /// Cart lines frozen at confirm — UI and sale must use this, not live cart.
  final List<CartItem>? frozenItems;

  CheckoutState copyWith({
    CheckoutStatus? status,
    Object? lastSale = _unset,
    Object? errorMessage = _unset,
    Object? promptPayAmount = _unset,
    Object? frozenItems = _unset,
  }) => CheckoutState(
    status: status ?? this.status,
    lastSale: identical(lastSale, _unset) ? this.lastSale : lastSale as Sale?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    promptPayAmount: identical(promptPayAmount, _unset)
        ? this.promptPayAmount
        : promptPayAmount as double?,
    frozenItems: identical(frozenItems, _unset)
        ? this.frozenItems
        : frozenItems as List<CartItem>?,
  );

  @override
  List<Object?> get props => [
    status,
    lastSale,
    errorMessage,
    promptPayAmount,
    frozenItems,
  ];
}
