import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

/// Canonical period aggregates for Report, Daily Close, Home, and Sale header.
///
/// Rules:
/// - Revenue / counts: [Sale.isVoided] is false (`!isVoided`)
/// - Voids: [Sale.isVoided]
/// - Payment keys: [normalizePaymentMethod] only
class SalesPeriodTotals extends Equatable {
  const SalesPeriodTotals({
    required this.netRevenue,
    required this.voidedTotal,
    required this.salesCount,
    required this.voidCount,
    required this.vatAmount,
    required this.discountAmount,
    required this.paymentBreakdown,
    required this.paymentCounts,
    this.serviceChargeAmount = Money.zero,
    this.promotionDiscountAmount = Money.zero,
    this.orderTypeBreakdown = const {},
    this.orderChannelBreakdown = const {},
    this.voidReasonBreakdown = const {},
    this.promotionCount = 0,
  });

  final Money netRevenue;
  final Money voidedTotal;
  final int salesCount;
  final int voidCount;
  final Money vatAmount;
  final Money discountAmount;
  final Money serviceChargeAmount;
  final Money promotionDiscountAmount;

  /// Revenue grouped by normalized order type.
  final Map<String, double> orderTypeBreakdown;

  /// Revenue grouped by normalized order channel.
  final Map<String, double> orderChannelBreakdown;

  /// Count of voids grouped by recorded reason.
  final Map<String, int> voidReasonBreakdown;

  /// Number of completed sales using a promotion.
  final int promotionCount;

  /// Manual/cart discount after promotion discount is removed.
  Money get cartDiscountAmount => discountAmount - promotionDiscountAmount;

  Money get grossRevenue => netRevenue + voidedTotal;

  Money get averageTransactionValue => salesCount == 0
      ? Money.zero
      : Money.fromSatang(netRevenue.satang ~/ salesCount);

  Money get cashSales => Money.fromDouble(paymentBreakdown['cash'] ?? 0);

  /// Normalized method → sum of tender line amounts.
  final Map<String, double> paymentBreakdown;

  /// Normalized method → count of tender legs.
  final Map<String, int> paymentCounts;

  factory SalesPeriodTotals.from(List<Sale> sales) {
    var net = Money.zero;
    var voided = Money.zero;
    var serviceCharge = Money.zero;
    var promotionDiscount = Money.zero;
    var salesCount = 0;
    var voidCount = 0;
    var vat = Money.zero;
    var discount = Money.zero;
    final breakdown = <String, double>{};
    final counts = <String, int>{};
    final orderTypes = <String, double>{};
    final orderChannels = <String, double>{};
    final voidReasons = <String, int>{};
    var promotionCount = 0;

    for (final sale in sales) {
      if (sale.isVoided) {
        voided += sale.totalAmount;
        voidCount++;
        final reason = sale.voidReason?.trim();
        final key = reason == null || reason.isEmpty ? 'unspecified' : reason;
        voidReasons[key] = (voidReasons[key] ?? 0) + 1;
        continue;
      }
      net += sale.totalAmount;
      salesCount++;
      vat += sale.vatAmount;
      discount += sale.discountAmount;
      serviceCharge += sale.serviceChargeAmount;
      promotionDiscount += sale.promotionDiscountAmount;
      if (sale.promotionId != null || sale.promotionDiscountAmount.isPositive) {
        promotionCount++;
      }
      orderTypes[sale.orderType] =
          (orderTypes[sale.orderType] ?? 0) + sale.totalAmount.value;
      orderChannels[sale.orderChannel] =
          (orderChannels[sale.orderChannel] ?? 0) + sale.totalAmount.value;

      if (sale.payments.isNotEmpty) {
        for (final pay in sale.payments) {
          final key = normalizePaymentMethod(pay.method);
          breakdown[key] = (breakdown[key] ?? 0) + pay.amount.value;
          counts[key] = (counts[key] ?? 0) + 1;
        }
      } else {
        final key = normalizePaymentMethod(sale.paymentMethod);
        breakdown[key] = (breakdown[key] ?? 0) + sale.totalAmount.value;
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    return SalesPeriodTotals(
      netRevenue: net,
      voidedTotal: voided,
      salesCount: salesCount,
      voidCount: voidCount,
      vatAmount: vat,
      discountAmount: discount,
      serviceChargeAmount: serviceCharge,
      promotionDiscountAmount: promotionDiscount,
      paymentBreakdown: Map.unmodifiable(breakdown),
      paymentCounts: Map.unmodifiable(counts),
      orderTypeBreakdown: Map.unmodifiable(orderTypes),
      orderChannelBreakdown: Map.unmodifiable(orderChannels),
      voidReasonBreakdown: Map.unmodifiable(voidReasons),
      promotionCount: promotionCount,
    );
  }

  static const empty = SalesPeriodTotals(
    netRevenue: Money.zero,
    voidedTotal: Money.zero,
    salesCount: 0,
    voidCount: 0,
    vatAmount: Money.zero,
    discountAmount: Money.zero,
    paymentBreakdown: {},
    paymentCounts: {},
  );

  @override
  List<Object?> get props => [
    netRevenue,
    voidedTotal,
    salesCount,
    voidCount,
    vatAmount,
    discountAmount,
    serviceChargeAmount,
    promotionDiscountAmount,
    paymentBreakdown,
    paymentCounts,
    orderTypeBreakdown,
    orderChannelBreakdown,
    voidReasonBreakdown,
    promotionCount,
  ];
}
