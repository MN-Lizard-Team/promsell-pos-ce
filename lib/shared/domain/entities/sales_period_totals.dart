import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

/// Canonical period aggregates for Report, Daily Close, Home, and Sale header.
///
/// Shared domain entity — used by report, daily close, home, and sale features.
/// Lives in `lib/shared/domain/` to avoid cross-feature domain coupling.
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
    final breakdownSatang = <String, int>{};
    final counts = <String, int>{};
    final orderTypesSatang = <String, int>{};
    final orderChannelsSatang = <String, int>{};
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
      orderTypesSatang[sale.orderType] =
          (orderTypesSatang[sale.orderType] ?? 0) + sale.totalAmount.satang;
      orderChannelsSatang[sale.orderChannel] =
          (orderChannelsSatang[sale.orderChannel] ?? 0) +
          sale.totalAmount.satang;

      if (sale.payments.isNotEmpty) {
        for (final pay in sale.payments) {
          final key = normalizePaymentMethod(pay.method);
          breakdownSatang[key] =
              (breakdownSatang[key] ?? 0) + pay.amount.satang;
          counts[key] = (counts[key] ?? 0) + 1;
        }
      } else {
        final key = normalizePaymentMethod(sale.paymentMethod);
        breakdownSatang[key] =
            (breakdownSatang[key] ?? 0) + sale.totalAmount.satang;
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
      paymentBreakdown: _toBahtMap(breakdownSatang),
      paymentCounts: Map.unmodifiable(counts),
      orderTypeBreakdown: _toBahtMap(orderTypesSatang),
      orderChannelBreakdown: _toBahtMap(orderChannelsSatang),
      voidReasonBreakdown: Map.unmodifiable(voidReasons),
      promotionCount: promotionCount,
    );
  }

  static Map<String, double> _toBahtMap(Map<String, int> satang) =>
      Map.unmodifiable({
        for (final entry in satang.entries) entry.key: entry.value / 100.0,
      });

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
