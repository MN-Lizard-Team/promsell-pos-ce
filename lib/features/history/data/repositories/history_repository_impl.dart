import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource);
  final SaleLocalDatasource _datasource;

  /// Upper bound for one-shot history loads. Callers expect a full list, so
  /// the cursor loop stays bounded instead of trusting the range. PDF export
  /// streams its own pagination and is not affected.
  static const _maxSales = 2000;

  @override
  Future<List<Sale>> getSales({DateTime? from, DateTime? to}) async {
    final sales = <Sale>[];
    SaleCursor? cursor;
    while (sales.length < _maxSales) {
      final page = await _datasource.querySalesPage(
        from: from,
        to: to,
        cursor: cursor,
        pageSize: 500,
      );
      sales.addAll(page.sales);
      if (!page.hasMore) break;
      cursor = page.nextCursor;
    }
    return sales;
  }

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _datasource.watchSales(from: from, to: to);
}
