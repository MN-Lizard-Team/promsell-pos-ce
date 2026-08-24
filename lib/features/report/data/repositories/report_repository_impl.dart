import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/report/domain/repositories/report_repository.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  const ReportRepositoryImpl(this._saleRepo, this._productRepo);

  final SaleRepository _saleRepo;
  final ProductRepository _productRepo;

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _saleRepo.watchSales(from: from, to: to);

  @override
  Future<List<Sale>> getSales({DateTime? from, DateTime? to}) =>
      _saleRepo.getSales(from: from, to: to);

  @override
  Future<Map<String, Product>> getProductCostLookup(
    List<String> productIds,
  ) async {
    final ids = productIds.toSet();
    final lookup = <String, Product>{};
    for (final id in ids) {
      final p = await _productRepo.getProductById(id);
      if (p != null) lookup[id] = p;
    }
    return lookup;
  }
}
