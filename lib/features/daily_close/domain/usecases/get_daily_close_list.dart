import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';

@injectable
class GetDailyCloseList {
  GetDailyCloseList(this._repository);

  final DailyCloseRepository _repository;

  Future<List<DailyClose>> call() => _repository.getAll();
}
