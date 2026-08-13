import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';

/// Blocks multi-bill switch/park while checkout freezes the cart.
///
/// Authoritative for UI; [DraftBloc] also rejects when [CartState.paymentLocked]
/// is true on park/newBill/switch events.
abstract final class DraftBillSwitchGuard {
  DraftBillSwitchGuard._();

  static const errorCode = 'paymentInProgress';

  static bool isBlocked({
    required bool paymentLocked,
    CheckoutStatus? checkoutStatus,
  }) {
    if (paymentLocked) return true;
    return checkoutStatus == CheckoutStatus.waitingPayment ||
        checkoutStatus == CheckoutStatus.processing;
  }

  static bool isBlockedFromStates({
    required CartState cart,
    CheckoutState? checkout,
  }) => isBlocked(
    paymentLocked: cart.paymentLocked,
    checkoutStatus: checkout?.status,
  );
}
