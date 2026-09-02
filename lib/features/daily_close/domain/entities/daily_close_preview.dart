import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

/// Read-only sales snapshot used before a day is closed.
///
/// This is deliberately separate from [DailyClose]: previewing a day must
/// never persist a close record or mutate lock state.
class DailyClosePreview extends Equatable {
  const DailyClosePreview({
    required this.salesCount,
    required this.voidCount,
    required this.netRevenue,
    required this.voidedTotal,
    required this.vatAmount,
    required this.discountAmount,
    required this.paymentBreakdown,
  });

  final int salesCount;
  final int voidCount;
  final Money netRevenue;
  final Money voidedTotal;
  final Money vatAmount;
  final Money discountAmount;
  final Map<String, double> paymentBreakdown;

  Money get cashSales => Money.fromDouble(paymentBreakdown['cash'] ?? 0);
  Money get grossRevenue => netRevenue + voidedTotal;

  static const empty = DailyClosePreview(
    salesCount: 0,
    voidCount: 0,
    netRevenue: Money.zero,
    voidedTotal: Money.zero,
    vatAmount: Money.zero,
    discountAmount: Money.zero,
    paymentBreakdown: {},
  );

  @override
  List<Object?> get props => [
    salesCount,
    voidCount,
    netRevenue,
    voidedTotal,
    vatAmount,
    discountAmount,
    paymentBreakdown,
  ];
}
