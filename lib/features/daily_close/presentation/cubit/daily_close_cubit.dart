import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/reopen_day.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

part 'daily_close_state.dart';

@injectable
class DailyCloseCubit extends Cubit<DailyCloseState> {
  DailyCloseCubit(
    this._closeDay,
    this._reopenDay,
    this._getByDate,
    this._settingsRepo,
    this._settingsCubit,
  ) : super(const DailyCloseState());

  final CloseDay _closeDay;
  final ReopenDay _reopenDay;
  final GetDailyCloseByDate _getByDate;
  final SettingsRepository _settingsRepo;
  final SettingsCubit _settingsCubit;

  Future<void> loadDate(String date, {String deviceId = ''}) async {
    emit(state.copyWith(status: DailyCloseStatus.loading, errorMessage: null));
    try {
      final existing = await _getByDate(date);
      if (existing != null && existing.isClosed) {
        emit(
          state.copyWith(
            status: DailyCloseStatus.closed,
            date: date,
            dailyClose: existing,
            openingCash: existing.openingCash.value,
            countedCash: existing.countedCash.value,
            note: existing.note ?? '',
          ),
        );
        return;
      }

      // For summary calculation, we need to query sales.
      // The CloseDay use case handles this; we'll call it with countedCash=0
      // just to get the summary, or we can calculate separately.
      // For now, emit ready with empty summary; the page will show form.
      emit(
        state.copyWith(
          status: DailyCloseStatus.ready,
          date: date,
          dailyClose: existing,
          openingCash: existing?.openingCash.value ?? 0,
        ),
      );
    } catch (e, stack) {
      AppLogger.error('DailyCloseCubit.load failed', error: e, stack: stack);
      emit(
        state.copyWith(
          status: DailyCloseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setCountedCash(double value) {
    emit(state.copyWith(countedCash: value));
  }

  void setOpeningCash(double value) {
    emit(state.copyWith(openingCash: value));
  }

  void setNote(String value) {
    emit(state.copyWith(note: value));
  }

  Future<void> closeDay({required String deviceId}) async {
    if (state.date == null) return;
    emit(state.copyWith(status: DailyCloseStatus.closing, errorMessage: null));
    try {
      final result = await _closeDay(
        date: state.date!,
        openingCash: state.openingCash,
        countedCash: state.countedCash,
        note: state.note.isEmpty ? null : state.note,
        deviceId: deviceId,
      );
      emit(state.copyWith(status: DailyCloseStatus.closed, dailyClose: result));
      final settings = await _settingsRepo.load();
      await _settingsRepo.save(settings.copyWith(lastClosedDate: state.date));
      // Checkout reads SettingsCubit memory — keep it in sync with repo.
      await _settingsCubit.load();
    } catch (e, stack) {
      AppLogger.error(
        'DailyCloseCubit.closeDay failed',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          status: DailyCloseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> reopenDay() async {
    if (state.date == null) return;
    emit(
      state.copyWith(status: DailyCloseStatus.reopening, errorMessage: null),
    );
    try {
      final result = await _reopenDay(state.date!);
      emit(
        state.copyWith(status: DailyCloseStatus.reopened, dailyClose: result),
      );
      final settings = await _settingsRepo.load();
      final reopened = state.date;
      if (reopened != null &&
          SalesDayLock.normalizeClosedDate(settings.lastClosedDate) ==
              reopened) {
        await _settingsRepo.save(settings.copyWith(lastClosedDate: null));
        await _settingsCubit.load();
      }
    } catch (e, stack) {
      AppLogger.error(
        'DailyCloseCubit.reopenDay failed',
        error: e,
        stack: stack,
      );
      emit(
        state.copyWith(
          status: DailyCloseStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
