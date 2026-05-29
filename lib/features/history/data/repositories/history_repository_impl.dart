import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource);
  final SaleLocalDatasource _datasource;

  @override
  Future<List<Sale>> getSales({DateTime? from, DateTime? to}) =>
      _datasource.querySales(from: from, to: to);

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _datasource.watchSales(from: from, to: to);
}
