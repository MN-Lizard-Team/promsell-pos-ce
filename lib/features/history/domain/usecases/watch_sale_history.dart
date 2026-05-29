import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

@injectable
class WatchSaleHistory {
  const WatchSaleHistory(this._repository);
  final HistoryRepository _repository;

  Stream<List<Sale>> call({DateTime? from, DateTime? to}) =>
      _repository.watchSales(from: from, to: to);
}
