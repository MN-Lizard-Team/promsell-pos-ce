import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class WatchRecentSales {
  const WatchRecentSales(this._repository);
  final SaleRepository _repository;

  Stream<List<Sale>> call({int limit = 20}) =>
      _repository.watchRecentSales(limit: limit);
}
