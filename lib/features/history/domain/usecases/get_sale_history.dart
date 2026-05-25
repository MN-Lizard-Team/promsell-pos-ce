import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

class GetSaleHistory {
  const GetSaleHistory(this._repository);
  final HistoryRepository _repository;

  Future<List<Sale>> call({DateTime? from, DateTime? to}) =>
      _repository.getSales(from: from, to: to);
}
