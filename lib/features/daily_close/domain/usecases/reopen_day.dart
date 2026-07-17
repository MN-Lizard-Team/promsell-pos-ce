import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';

@injectable
class ReopenDay {
  ReopenDay(this._repository);

  final DailyCloseRepository _repository;

  Future<DailyClose> call(String date) async {
    final existing = await _repository.getByDate(date);
    if (existing == null) {
      throw StateError('No close record found for $date');
    }
    if (!existing.isClosed) {
      throw StateError('Day $date is not closed');
    }

    final reopened = existing.copyWith(
      closedAt: null,
      countedCash: Money.zero,
      overShortAmount: Money.zero,
      note: null,
    );

    return _repository.save(reopened);
  }
}
