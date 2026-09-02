import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/table_sales_stat.dart';
import 'package:promsell_pos_ce/features/report/domain/repositories/report_repository.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@LazySingleton(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(
    this._saleRepo,
    this._productRepo,
    this._queryDatasource,
  );

  final SaleRepository _saleRepo;
  final ProductRepository _productRepo;
  final SaleQueryLocalDatasource _queryDatasource;

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _saleRepo.watchSales(from: from, to: to);

  @override
  Future<List<Sale>> getSales({DateTime? from, DateTime? to}) =>
      _saleRepo.getSales(from: from, to: to);

  @override
  Stream<ReportAggregate> watchReportAggregate({
    DateTime? from,
    DateTime? to,
  }) => _saleRepo.watchReportAggregate(from: from, to: to);

  @override
  Stream<List<TableSalesStat>> watchTableSalesStats({
    DateTime? from,
    DateTime? to,
  }) => _queryDatasource
      .watchTableSalesStats(from: from, to: to)
      .map(_foldNoTableBucket);

  /// Maps the datasource's raw NULL table id onto the explicit no-table
  /// bucket sentinel so UI layers never handle a null id.
  List<TableSalesStat> _foldNoTableBucket(List<TableSalesStat> rows) => [
    for (final row in rows)
      TableSalesStat(
        tableId: row.tableId,
        orderCount: row.orderCount,
        revenueSatang: row.revenueSatang,
        lastSaleAt: row.lastSaleAt,
      ),
  ];

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
