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
  });

  final Money netRevenue;
  final Money voidedTotal;
  final int salesCount;
  final int voidCount;
  final Money vatAmount;
  final Money discountAmount;

  /// Normalized method → sum of [Sale.totalAmount] for non-void sales.
  final Map<String, double> paymentBreakdown;

  /// Normalized method → bill count for non-void sales.
  final Map<String, int> paymentCounts;

  Money get cashSales => Money.fromDouble(paymentBreakdown['cash'] ?? 0);

  Money get grossRevenue => netRevenue + voidedTotal;

  factory SalesPeriodTotals.from(List<Sale> sales) {
    var net = Money.zero;
    var voided = Money.zero;
    var salesCount = 0;
    var voidCount = 0;
    var vat = Money.zero;
    var discount = Money.zero;
    final breakdown = <String, double>{};
    final counts = <String, int>{};

    for (final sale in sales) {
      if (sale.isVoided) {
        voided += sale.totalAmount;
        voidCount++;
        continue;
      }
      net += sale.totalAmount;
      salesCount++;
      vat += sale.vatAmount;
      discount += sale.discountAmount;
      if (sale.payments.isNotEmpty) {
        for (final pay in sale.payments) {
          final key = normalizePaymentMethod(pay.method);
          breakdown[key] = (breakdown[key] ?? 0) + pay.amount.value;
        }
        final headerKey = normalizePaymentMethod(sale.paymentMethod);
        counts[headerKey] = (counts[headerKey] ?? 0) + 1;
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
      paymentBreakdown: Map.unmodifiable(breakdown),
      paymentCounts: Map.unmodifiable(counts),
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
    paymentBreakdown,
    paymentCounts,
  ];
}
