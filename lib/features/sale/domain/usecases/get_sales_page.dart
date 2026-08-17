import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class GetSalesPage {
  const GetSalesPage(this._repository);
  final SaleRepository _repository;

  Future<SalePage> call({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
  }) => _repository.getSalesPage(
    from: from,
    to: to,
    cursor: cursor,
    pageSize: pageSize,
  );
}

@injectable
class GetSalesCount {
  const GetSalesCount(this._repository);
  final SaleRepository _repository;

  Future<int> call({DateTime? from, DateTime? to}) =>
      _repository.getSalesCount(from: from, to: to);
}
