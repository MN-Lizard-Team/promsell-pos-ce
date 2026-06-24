import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';
import 'package:promsell_pos_ce/features/report/presentation/cubit/report_state.dart';

@lazySingleton
class ReportCubit extends Cubit<ReportState> {
  ReportCubit({required WatchReport watchReport})
    : _watchReport = watchReport,
      super(
        ReportState(
          from: DateTime.now()
              .subtract(const Duration(days: 30))
              .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
          to: DateTime.now().copyWith(
            hour: 23,
            minute: 59,
            second: 59,
            millisecond: 999,
          ),
        ),
      );

  final WatchReport _watchReport;
  StreamSubscription? _sub;

  Future<void> load() async {
    final now = DateTime.now();
    final to =
        state.to?.day != now.day ||
            state.to?.month != now.month ||
            state.to?.year != now.year
        ? now.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999)
        : state.to;

    emit(state.copyWith(status: ReportStatus.loading, to: to));
    await _sub?.cancel();
    _sub = _watchReport(from: state.from, to: to).listen(
      (sales) {
        if (isClosed) return;
        emit(state.copyWith(status: ReportStatus.success, sales: sales));
      },
      onError: (e) {
        AppLogger.error('ReportCubit.load failed', error: e);
        if (isClosed) return;
        emit(state.copyWith(status: ReportStatus.failure));
      },
    );
  }

  Future<void> changeDateRange(DateTime from, DateTime to) async {
    emit(state.copyWith(from: from, to: to, status: ReportStatus.loading));
    await _sub?.cancel();
    _sub = _watchReport(from: from, to: to).listen(
      (sales) {
        if (isClosed) return;
        emit(state.copyWith(status: ReportStatus.success, sales: sales));
      },
      onError: (e) {
        AppLogger.error('ReportCubit.changeDateRange failed', error: e);
        if (isClosed) return;
        emit(state.copyWith(status: ReportStatus.failure));
      },
    );
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
