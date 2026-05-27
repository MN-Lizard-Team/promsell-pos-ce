import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

class VoidSale {
  const VoidSale(this._repository);
  final SaleRepository _repository;

  Future<void> call(String saleId, {String? reason}) =>
      _repository.voidSale(saleId, reason: reason);
}
