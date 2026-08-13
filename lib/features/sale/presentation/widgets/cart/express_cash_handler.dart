import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Pure helper for express cash payment (long-press Pay in retail mode).
abstract final class ExpressCashHandler {
  ExpressCashHandler._();

  static DateTime? _lastPayAt;

  /// Debounce window for double long-press (Wave P4).
  @visibleForTesting
  static const debounce = Duration(milliseconds: 800);

  /// Test-only: clear debounce clock.
  @visibleForTesting
  static void resetDebounceForTest() => _lastPayAt = null;

  /// Execute express cash: exact amount, no payment sheet.
  /// Falls back to full checkout in restaurant mode or when day is closed.
  static void pay({
    required BuildContext context,
    required CartState cart,
    required Settings settings,
  }) {
    if (cart.isEmpty) return;
    if (cart.paymentLocked) return;

    final now = DateTime.now();
    final last = _lastPayAt;
    if (last != null && now.difference(last) < debounce) return;
    _lastPayAt = now;

    if (SalesDayLock.isCreateBlocked(
      dailyCloseLock: settings.dailyCloseLock,
      lastClosedDate: settings.lastClosedDate,
    )) {
      AppSnackBar.error(context, context.l10n.dayClosedMessage);
      return;
    }
    if (settings.isRestaurantMode) {
      navigateToCheckout(context);
      return;
    }
    final payable = cart.payableTotals(settings);
    final due = payable.payableTotal;
    context.read<CheckoutBloc>().add(
      CheckoutConfirmed(
        paymentMethod: 'cash',
        vatMode: settings.vatMode,
        vatRate: settings.vatRate,
        cartDiscountType: cart.cartDiscountType,
        cartDiscountValue: cart.cartDiscountValue,
        cartDiscountAmount: cart.cartDiscountAmount,
        amountReceived: due,
        changeAmount: Money.zero,
        note: cart.note.isEmpty ? null : cart.note,
        orderType: cart.orderType,
        orderChannel: cart.orderChannel,
        externalOrderRef: cart.externalOrderRef,
        tableId: cart.tableId,
        serviceChargeRate: payable.serviceChargeRate,
        serviceChargeAmount: payable.serviceChargeAmount,
      ),
    );
  }
}
