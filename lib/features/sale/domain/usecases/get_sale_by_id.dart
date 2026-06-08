import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class GetSaleById {
  const GetSaleById(this._repository);
  final SaleRepository _repository;

  Future<Sale?> call(String id) => _repository.getSaleById(id);
}
