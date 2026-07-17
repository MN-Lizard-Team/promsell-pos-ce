import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';

@injectable
class VoidSale {
  const VoidSale(
    this._repository,
    this._settingsRepo,
    this._getDailyCloseByDate,
  );
  final SaleRepository _repository;
  final SettingsRepository _settingsRepo;
  final GetDailyCloseByDate _getDailyCloseByDate;

  Future<void> call(String saleId, {String? reason}) async {
    final sale = await _repository.getSaleById(saleId);
    if (sale == null) {
      throw const NotFoundError('Sale');
    }

    final settings = await _settingsRepo.load();
    final saleDate = SalesDayLock.dateIso(sale.createdAt);
    final dayRow = await _getDailyCloseByDate(saleDate);
    final dayRowClosed = dayRow?.isClosed == true;

    if (SalesDayLock.isVoidBlocked(
      dailyCloseLock: settings.dailyCloseLock,
      lastClosedDate: settings.lastClosedDate,
      saleCreatedAt: sale.createdAt,
      dayRowClosed: dayRowClosed,
    )) {
      throw const BusinessRuleError(SalesDayLock.ruleDayClosed);
    }

    await _repository.voidSale(saleId, reason: reason);
  }
}
