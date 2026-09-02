import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sales_period_totals.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class CloseDay {
  CloseDay(this._repository, this._saleRepository, this._appLock);

  final DailyCloseRepository _repository;
  final SaleRepository _saleRepository;
  final AppLockService _appLock;

  /// Throws [BusinessRuleError] `AppLockRequired` when store PIN is on and
  /// session locked (V092-B.3).
  Future<DailyClose> call({
    required String date,
    required double openingCash,
    required double countedCash,
    String? note,
    required String deviceId,
  }) async {
    _validateInputs(
      date: date,
      openingCash: openingCash,
      countedCash: countedCash,
    );
    await _appLock.requireSensitiveSession();
    final existing = await _repository.getByDate(date);
    if (existing != null && existing.isClosed) {
      throw StateError('Day $date is already closed');
    }

    final dayStart = DateTime.parse('${date}T00:00:00');
    final dayEnd = DateTime.parse('${date}T23:59:59.999');

    final sales = await _saleRepository.getSales(from: dayStart, to: dayEnd);
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
      discountAmount: totals.discountAmount + totals.promotionDiscountAmount,
      note: note,
      closedAt: DateTime.now(),
      deviceId: deviceId,
    );

    return _repository.save(dailyClose);
  }

  void _validateInputs({
    required String date,
    required double openingCash,
    required double countedCash,
  }) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date) ||
        '${parsed.year.toString().padLeft(4, '0')}-'
                '${parsed.month.toString().padLeft(2, '0')}-'
                '${parsed.day.toString().padLeft(2, '0')}' !=
            date) {
      throw ArgumentError.value(date, 'date', 'Expected yyyy-MM-dd');
    }
    if (!openingCash.isFinite || openingCash < 0) {
      throw ArgumentError.value(
        openingCash,
        'openingCash',
        'Must be finite and non-negative',
      );
    }
    if (!countedCash.isFinite || countedCash < 0) {
      throw ArgumentError.value(
        countedCash,
        'countedCash',
        'Must be finite and non-negative',
      );
    }
  }
}
