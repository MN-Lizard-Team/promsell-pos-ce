import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/utils/money_utils.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';

@injectable
class CloseDay {
  CloseDay(this._repository, this._saleDatasource);

  final DailyCloseRepository _repository;
  final SaleLocalDatasource _saleDatasource;

  Future<DailyClose> call({
    required String date,
    required double openingCash,
    required double countedCash,
    String? note,
    required String deviceId,
  }) async {
    final existing = await _repository.getByDate(date);
    if (existing != null && existing.isClosed) {
      throw StateError('Day $date is already closed');
    }

    // Parse date boundaries
    final dayStart = DateTime.parse('${date}T00:00:00');
    final dayEnd = DateTime.parse('${date}T23:59:59.999');

    final sales = await _saleDatasource.querySales(from: dayStart, to: dayEnd);

    double totalRevenue = 0;
    double totalVoid = 0;
    int salesCount = 0;
    int voidCount = 0;
    double vatAmount = 0;
    double discountAmount = 0;
    final paymentBreakdown = <String, double>{};

    for (final sale in sales) {
      if (sale.status == 'COMPLETED') {
        totalRevenue += sale.totalAmount;
        salesCount++;
        vatAmount += sale.vatAmount;
        discountAmount += sale.discountAmount;
        final method = _normalizePaymentMethod(sale.paymentMethod);
        paymentBreakdown[method] =
            (paymentBreakdown[method] ?? 0) + sale.totalAmount;
      } else if (sale.status == 'VOIDED') {
        totalVoid += sale.totalAmount;
        voidCount++;
      }
    }

    totalRevenue = MoneyUtils.round(totalRevenue);
    totalVoid = MoneyUtils.round(totalVoid);
    vatAmount = MoneyUtils.round(vatAmount);
    discountAmount = MoneyUtils.round(discountAmount);

    final cashSales = paymentBreakdown['cash'] ?? 0;
    final expectedCash = MoneyUtils.round(openingCash + cashSales);
    final overShort = MoneyUtils.round(countedCash - expectedCash);

    final dailyClose = DailyClose(
      id: existing?.id ?? IdGenerator.newId(),
      closeDate: date,
      openingCash: openingCash,
      expectedCash: expectedCash,
      countedCash: countedCash,
      overShortAmount: overShort,
      totalRevenue: totalRevenue,
      totalVoid: totalVoid,
      salesCount: salesCount,
      voidCount: voidCount,
      paymentBreakdown: paymentBreakdown,
      vatAmount: vatAmount,
      discountAmount: discountAmount,
      note: note,
      closedAt: DateTime.now(),
      deviceId: deviceId,
    );

    return _repository.save(dailyClose);
  }

  String _normalizePaymentMethod(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('cash') || lower == 'เงินสด') return 'cash';
    if (lower.contains('promptpay') || lower.contains('prompt pay')) {
      return 'promptpay';
    }
    if (lower.contains('card') || lower.contains('credit')) return 'card';
    return lower;
  }
}
