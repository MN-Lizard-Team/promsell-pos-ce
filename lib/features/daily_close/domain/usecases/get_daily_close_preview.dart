import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close_preview.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class GetDailyClosePreview {
  const GetDailyClosePreview(this._saleRepository);

  final SaleRepository _saleRepository;

  Future<DailyClosePreview> call(String date) async {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
      throw FormatException('Expected yyyy-MM-dd', date);
    }
    final dayStart = DateTime.parse('${date}T00:00:00');
    final dayEnd = DateTime.parse('${date}T23:59:59.999');
    final summary = await _saleRepository.getReportSummary(
      from: dayStart,
      to: dayEnd,
    );

    return DailyClosePreview(
      salesCount: summary.salesCount,
      voidCount: summary.voidCount,
      netRevenue: summary.netRevenue,
      voidedTotal: summary.voidedTotal,
      vatAmount: summary.vatAmount,
      discountAmount: summary.discountAmount + summary.promotionDiscountAmount,
      paymentBreakdown: summary.paymentBreakdown,
    );
  }
}
