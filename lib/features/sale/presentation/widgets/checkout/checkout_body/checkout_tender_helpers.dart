import 'package:flutter/widgets.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

/// Pure helpers for checkout tender construction and error mapping.
abstract final class CheckoutTenderHelpers {
  CheckoutTenderHelpers._();

  static List<SalePayment> buildTenders({
    required bool splitTender,
    required String method,
    required Money payableTotal,
    required String reference,
    required String splitCashText,
  }) {
    final ref = reference.trim().isEmpty ? null : reference.trim();
    if (!splitTender) {
      return [
        SalePayment(method: method, amount: payableTotal, reference: ref),
      ];
    }
    final cashPart = Money.fromDouble(double.tryParse(splitCashText) ?? 0);
    final other = remainingOtherAmount(
      payableTotal: payableTotal,
      splitCashText: splitCashText,
    );
    final otherMethod = method == 'cash' ? 'promptpay' : method;
    return [
      if (cashPart > Money.zero)
        SalePayment(method: 'cash', amount: cashPart, sortOrder: 0),
      if (other > Money.zero)
        SalePayment(
          method: otherMethod,
          amount: other,
          reference: ref,
          sortOrder: 1,
        ),
    ];
  }

  /// Display/SSOT helper: other-leg amount for split tender (same clamp as
  /// [buildTenders]). Does not insert payments.
  static Money remainingOtherAmount({
    required Money payableTotal,
    required String splitCashText,
  }) {
    final cashPart = Money.fromDouble(double.tryParse(splitCashText) ?? 0);
    return (payableTotal - cashPart).clampToZero();
  }

  /// Cash change against the **cash tender leg**, not the full bill (Wave P2).
  ///
  /// - Pure cash (cash leg == payable): change = max(0, received − payable)
  /// - Split / mixed with cash leg: change = max(0, received − cashTender)
  /// - No cash leg: 0
  static double changeForCashLeg({
    required double received,
    required double payableTotal,
    required double cashTenderAmount,
  }) {
    if (cashTenderAmount <= 0) return 0;
    final base = cashTenderAmount;
    final change = received - base;
    return change > 0 ? change : 0;
  }

  static List<double> quickAmounts(double total) {
    final roundedTen = (total / 10).ceil() * 10.0;
    final roundedHundred = (total / 100).ceil() * 100.0;
    final nextTen = roundedTen > total ? roundedTen : roundedTen + 10;
    final nextHundred = roundedHundred > total
        ? roundedHundred
        : roundedHundred + 100;
    final unique = <double>{
      total,
      nextTen,
      nextHundred,
    }.where((v) => v > 0).toList()..sort();
    if (unique.length < 2) {
      unique.add(total + 20);
      unique.sort();
    }
    return unique;
  }

  static String localizeCheckoutError(BuildContext ctx, String? key) {
    final l10n = ctx.l10n;
    return switch (key) {
      'cartEmpty' => l10n.cartEmpty,
      'insufficientStock' => l10n.insufficientStock,
      'productNotFound' => l10n.productNotFound,
      'productInactive' => l10n.productInactive,
      'customerNotFound' => l10n.customerNotFound,
      'promotionNotFound' => l10n.promotionNotFound,
      'saleNotFound' => l10n.saleNotFound,
      'saleAlreadyVoided' => l10n.saleAlreadyVoided,
      'notFound' => l10n.notFound,
      'validationError' => l10n.validationError,
      'databaseError' => l10n.databaseError,
      'saleError' => l10n.saleError,
      'dayClosed' => l10n.dayClosedMessage,
      'paymentMismatch' => l10n.paymentMismatch,
      'tableAlreadyBound' => l10n.tableAlreadyBound,
      null => l10n.saleError,
      _ => l10n.saleError,
    };
  }
}
