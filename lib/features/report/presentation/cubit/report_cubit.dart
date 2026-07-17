import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';

@lazySingleton
class ReportCubit extends Cubit<ReportState> {
  ReportCubit({required WatchReport watchReport})
    : _watchReport = watchReport,
      super(
        ReportState(
          from: DateRangePresets.today().$1,
          to: DateRangePresets.today().$2,
        ),
      );

  final WatchReport _watchReport;
  StreamSubscription? _sub;

  /// Resets range to today and (re)subscribes. Call when opening Report page.
  Future<void> openToday() async {
    final range = DateRangePresets.today();
    await changeDateRange(range.$1, range.$2);
  }

  Future<void> load() async {
    final from = state.from ?? DateRangePresets.today().$1;
    final to = state.to ?? DateRangePresets.today().$2;
    await changeDateRange(from, to);
  }

  Future<void> changeDateRange(DateTime from, DateTime to) async {
    // Clear sales so UI cannot present previous-period totals as current truth.
    emit(
      state.copyWith(
        from: from,
        to: to,
        status: ReportStatus.loading,
        sales: const [],
      ),
    );
    await _sub?.cancel();
    _sub = _watchReport(from: from, to: to).listen(
      (sales) {
        if (isClosed) return;
        emit(state.copyWith(status: ReportStatus.success, sales: sales));
      },
      onError: (e) {
        AppLogger.error('ReportCubit.changeDateRange failed', error: e);
        if (isClosed) return;
        emit(state.copyWith(status: ReportStatus.failure, sales: const []));
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
