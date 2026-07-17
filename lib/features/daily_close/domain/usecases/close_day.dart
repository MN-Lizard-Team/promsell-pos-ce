import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';

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

    final dayStart = DateTime.parse('${date}T00:00:00');
    final dayEnd = DateTime.parse('${date}T23:59:59.999');

    final sales = await _saleDatasource.querySales(from: dayStart, to: dayEnd);
    final totals = SalesPeriodTotals.from(sales);

    final cashSales = totals.cashSales.value;
    final expectedCash = openingCash + cashSales;
    final overShort = countedCash - expectedCash;

    final dailyClose = DailyClose(
      id: existing?.id ?? IdGenerator.newId(),
      closeDate: date,
      openingCash: Money.fromDouble(openingCash),
      expectedCash: Money.fromDouble(expectedCash),
      countedCash: Money.fromDouble(countedCash),
      overShortAmount: Money.fromDouble(overShort),
      totalRevenue: totals.netRevenue,
      totalVoid: totals.voidedTotal,
      salesCount: totals.salesCount,
      voidCount: totals.voidCount,
      paymentBreakdown: Map<String, double>.from(totals.paymentBreakdown),
      vatAmount: totals.vatAmount,
      discountAmount: totals.discountAmount,
      note: note,
      closedAt: DateTime.now(),
      deviceId: deviceId,
    );

    return _repository.save(dailyClose);
  }
}
