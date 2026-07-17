import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// Inputs for [SalePayableCalculator.compute].
class SalePayableInput extends Equatable {
  const SalePayableInput({
    required this.itemsSubtotal,
    Money? cartDiscountAmount,
    Money? promotionDiscountAmount,
    this.serviceChargeRate = 0,
    this.vatMode = 'NONE',
    this.vatRate = 0,
  }) : cartDiscountAmount = cartDiscountAmount ?? Money.zero,
       promotionDiscountAmount = promotionDiscountAmount ?? Money.zero;

  final Money itemsSubtotal;
  final Money cartDiscountAmount;
  final Money promotionDiscountAmount;

  /// Already-resolved rate (0 when not restaurant / disabled).
  final double serviceChargeRate;
  final String vatMode;
  final double vatRate;

  @override
  List<Object?> get props => [
    itemsSubtotal,
    cartDiscountAmount,
    promotionDiscountAmount,
    serviceChargeRate,
    vatMode,
    vatRate,
  ];
}

/// Single source of truth for cart display, checkout charge, and sale insert.
class SalePayableTotals extends Equatable {
  const SalePayableTotals({
    required this.itemsSubtotal,
    required this.cartDiscountAmount,
    required this.promotionDiscountAmount,
    required this.netAfterDiscounts,
    required this.serviceChargeAmount,
    required this.preTaxTotal,
    required this.vatAmount,
    required this.netOfVat,
    required this.payableTotal,
    required this.serviceChargeRate,
    required this.vatMode,
    required this.vatRate,
    required this.isVatInclusive,
  });

  final Money itemsSubtotal;
  final Money cartDiscountAmount;
  final Money promotionDiscountAmount;

  /// Items − cart discount − promo (before SC / VAT).
  final Money netAfterDiscounts;
  final Money serviceChargeAmount;

  /// Net + service charge (base used for VAT exclusive add / inclusive extract).
  final Money preTaxTotal;
  final Money vatAmount;

  /// Exclusive: preTax; Inclusive: preTax − vat; None: preTax.
  final Money netOfVat;

  /// Customer charge / DB [totalAmount].
  final Money payableTotal;
  final double serviceChargeRate;
  final String vatMode;
  final double vatRate;
  final bool isVatInclusive;

  @override
  List<Object?> get props => [
    itemsSubtotal,
    cartDiscountAmount,
    promotionDiscountAmount,
    netAfterDiscounts,
    serviceChargeAmount,
    preTaxTotal,
    vatAmount,
    netOfVat,
    payableTotal,
    serviceChargeRate,
    vatMode,
    vatRate,
    isVatInclusive,
  ];
}

/// Domain payable calculator (Money satang arithmetic).
///
/// Rules match historical `insertSaleWithItems` pre-tax + VAT split:
/// - net = max(0, items − cartDisc − promo)
/// - sc = net × rate/100
/// - preTax = net + sc
/// - EXCLUSIVE: vat = preTax × r; payable = preTax + vat
/// - INCLUSIVE: netOfVat = preTax / (1+r); vat = preTax − netOfVat; payable = preTax
/// - NONE: vat = 0; payable = preTax
abstract final class SalePayableCalculator {
  /// Restaurant: cart rate ?? settings default; else 0.
  static double resolvedServiceChargeRate({
    required Settings settings,
    double? cartServiceChargeRate,
  }) {
    if (!settings.isRestaurantMode) return 0;
    final rate = cartServiceChargeRate ?? settings.defaultServiceChargeRate;
    if (rate <= 0) return 0;
    return rate;
  }

  /// Build input from cart money fields + shop settings (SC + VAT resolved).
  static SalePayableInput fromCartFields({
    required Money itemsSubtotal,
    required Money cartDiscountAmount,
    required Money promotionDiscountAmount,
    required Settings settings,
    double? cartServiceChargeRate,
  }) {
    return SalePayableInput(
      itemsSubtotal: itemsSubtotal,
      cartDiscountAmount: cartDiscountAmount,
      promotionDiscountAmount: promotionDiscountAmount,
      serviceChargeRate: resolvedServiceChargeRate(
        settings: settings,
        cartServiceChargeRate: cartServiceChargeRate,
      ),
      vatMode: settings.vatMode,
      vatRate: settings.vatRate,
    );
  }

  static SalePayableTotals compute(SalePayableInput input) {
    final net =
        (input.itemsSubtotal -
                input.cartDiscountAmount -
                input.promotionDiscountAmount)
            .clampToZero();
    final rate = input.serviceChargeRate;
    final sc = rate > 0 ? net * (rate / 100) : Money.zero;
    return _finish(input: input, net: net, sc: sc, rate: rate);
  }

  /// Same as [compute] but uses an explicit service-charge amount (insert path).
  static SalePayableTotals computeWithServiceChargeAmount(
    SalePayableInput input, {
    required Money serviceChargeAmount,
  }) {
    final net =
        (input.itemsSubtotal -
                input.cartDiscountAmount -
                input.promotionDiscountAmount)
            .clampToZero();
    return _finish(
      input: input,
      net: net,
      sc: serviceChargeAmount.clampToZero(),
      rate: input.serviceChargeRate,
    );
  }

  static SalePayableTotals _finish({
    required SalePayableInput input,
    required Money net,
    required Money sc,
    required double rate,
  }) {
    final preTax = (net + sc).clampToZero();
    final mode = input.vatMode.toUpperCase();
    final r = input.vatRate / 100;

    if (mode == 'INCLUSIVE' && r > 0) {
      final netOfVat = preTax * (1 / (1 + r));
      final vat = preTax - netOfVat;
      return SalePayableTotals(
        itemsSubtotal: input.itemsSubtotal,
        cartDiscountAmount: input.cartDiscountAmount,
        promotionDiscountAmount: input.promotionDiscountAmount,
        netAfterDiscounts: net,
        serviceChargeAmount: sc,
        preTaxTotal: preTax,
        vatAmount: vat,
        netOfVat: netOfVat,
        payableTotal: preTax,
        serviceChargeRate: rate,
        vatMode: mode,
        vatRate: input.vatRate,
        isVatInclusive: true,
      );
    }

    if (mode == 'EXCLUSIVE' && r > 0) {
      final vat = preTax * r;
      return SalePayableTotals(
        itemsSubtotal: input.itemsSubtotal,
        cartDiscountAmount: input.cartDiscountAmount,
        promotionDiscountAmount: input.promotionDiscountAmount,
        netAfterDiscounts: net,
        serviceChargeAmount: sc,
        preTaxTotal: preTax,
        vatAmount: vat,
        netOfVat: preTax,
        payableTotal: preTax + vat,
        serviceChargeRate: rate,
        vatMode: mode,
        vatRate: input.vatRate,
        isVatInclusive: false,
      );
    }

    return SalePayableTotals(
      itemsSubtotal: input.itemsSubtotal,
      cartDiscountAmount: input.cartDiscountAmount,
      promotionDiscountAmount: input.promotionDiscountAmount,
      netAfterDiscounts: net,
      serviceChargeAmount: sc,
      preTaxTotal: preTax,
      vatAmount: Money.zero,
      netOfVat: preTax,
      payableTotal: preTax,
      serviceChargeRate: rate,
      vatMode: mode == 'INCLUSIVE' || mode == 'EXCLUSIVE' ? mode : 'NONE',
      vatRate: input.vatRate,
      isVatInclusive: false,
    );
  }

  /// Convenience from cart field bundle + settings.
  static SalePayableTotals forCartFields({
    required Money itemsSubtotal,
    required Money cartDiscountAmount,
    required Money promotionDiscountAmount,
    required Settings settings,
    double? cartServiceChargeRate,
  }) => compute(
    fromCartFields(
      itemsSubtotal: itemsSubtotal,
      cartDiscountAmount: cartDiscountAmount,
      promotionDiscountAmount: promotionDiscountAmount,
      settings: settings,
      cartServiceChargeRate: cartServiceChargeRate,
    ),
  );
}
