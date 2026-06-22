import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

const Object _unset = Object();

enum CheckoutStatus { idle, processing, waitingPayment, success, failure }

class CheckoutState extends Equatable {
  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.lastSale,
    this.errorMessage,
  });

  final CheckoutStatus status;
  final Sale? lastSale;
  final String? errorMessage;

  CheckoutState copyWith({
    CheckoutStatus? status,
    Object? lastSale = _unset,
    Object? errorMessage = _unset,
  }) => CheckoutState(
    status: status ?? this.status,
    lastSale: identical(lastSale, _unset) ? this.lastSale : lastSale as Sale?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
  );

  @override
  List<Object?> get props => [status, lastSale, errorMessage];
}
