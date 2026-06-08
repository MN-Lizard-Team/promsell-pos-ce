import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class GetSales {
  const GetSales(this._repository);
  final SaleRepository _repository;

  Future<List<Sale>> call({DateTime? from, DateTime? to}) =>
      _repository.getSales(from: from, to: to);
}
