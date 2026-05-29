import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class WatchReport {
  const WatchReport(this._repository);
  final SaleRepository _repository;

  Stream<List<Sale>> call({DateTime? from, DateTime? to}) =>
      _repository.watchSales(from: from, to: to);
}
