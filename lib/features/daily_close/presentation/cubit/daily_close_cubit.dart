import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close_preview.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_by_date.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/get_daily_close_preview.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/reopen_day.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

part 'daily_close_state.dart';

@injectable
class DailyCloseCubit extends Cubit<DailyCloseState> {
  DailyCloseCubit(
    this._closeDay,
    this._reopenDay,
    this._getByDate,
    this._getPreview,
    this._settingsRepo,
    this._settingsCubit,
  ) : super(const DailyCloseState());

  final CloseDay _closeDay;
  final ReopenDay _reopenDay;
  final GetDailyCloseByDate _getByDate;
  final GetDailyClosePreview _getPreview;
  final SettingsRepository _settingsRepo;
  final SettingsCubit _settingsCubit;

  Future<void> loadDate(String date, {String deviceId = ''}) async {
    emit(
      state.copyWith(
        status: DailyCloseStatus.loading,
        date: date,
        clearDailyClose: true,
        clearPreview: true,
        countedCash: 0,
        openingCash: 0,
        note: '',
        clearError: true,
      ),
    );
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
            clearPreview: true,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: DailyCloseStatus.calculating,
          dailyClose: existing,
          openingCash: existing?.openingCash.value ?? 0,
        ),
      );
      final preview = await _getPreview(date);
      emit(
        state.copyWith(
          status: DailyCloseStatus.ready,
          date: date,
          dailyClose: existing,
          preview: preview,
          openingCash: existing?.openingCash.value ?? 0,
          countedCash: existing?.countedCash.value ?? 0,
          note: existing?.note ?? '',
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
    emit(state.copyWith(status: DailyCloseStatus.closing, clearError: true));
    try {
      final result = await _closeDay(
        date: state.date!,
        openingCash: state.openingCash,
        countedCash: state.countedCash,
        note: state.note.isEmpty ? null : state.note,
        deviceId: deviceId,
      );
      emit(
        state.copyWith(
          status: DailyCloseStatus.closed,
          dailyClose: result,
          clearPreview: true,
          openingCash: result.openingCash.value,
          countedCash: result.countedCash.value,
          note: result.note ?? '',
        ),
      );
      final settings = await _settingsRepo.load();
      await _settingsRepo.save(settings.copyWith(lastClosedDate: state.date));
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
    emit(state.copyWith(status: DailyCloseStatus.reopening, clearError: true));
    try {
      final result = await _reopenDay(state.date!);
      final settings = await _settingsRepo.load();
      final reopened = state.date;
      if (reopened != null &&
          SalesDayLock.normalizeClosedDate(settings.lastClosedDate) ==
              reopened) {
        await _settingsRepo.save(settings.copyWith(lastClosedDate: null));
        await _settingsCubit.load();
      }
      final preview = await _getPreview(state.date!);
      emit(
        state.copyWith(
          status: DailyCloseStatus.reopened,
          dailyClose: result,
          preview: preview,
          openingCash: result.openingCash.value,
          countedCash: 0,
          note: '',
        ),
      );
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
