import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._datasource);
  final SaleLocalDatasource _datasource;

  @override
  /// Loads every matching sale through the cursor API. The caller receives a
  /// complete range; pagination is internal for legacy callers that still
  /// expect a list.
  Future<List<Sale>> getSales({DateTime? from, DateTime? to}) async {
    final sales = <Sale>[];
    SaleCursor? cursor;
    final seenCursors = <String>{};
    while (true) {
      final page = await _datasource.querySalesPage(
        from: from,
        to: to,
        cursor: cursor,
        pageSize: 500,
      );
      sales.addAll(page.sales);
      if (!page.hasMore) break;
      final next = page.nextCursor;
      if (next == null) {
        throw StateError('Sale history pagination returned no next cursor');
      }
      final cursorKey = '${next.createdAt.microsecondsSinceEpoch}:${next.id}';
      if (!seenCursors.add(cursorKey)) {
        throw StateError('Sale history pagination repeated a cursor');
      }
      cursor = next;
    }
    return sales;
  }

  @override
  Future<SalePage> getSalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
    String? searchQuery,
  }) => _datasource.querySalesPage(
    from: from,
    to: to,
    cursor: cursor,
    pageSize: pageSize,
    searchQuery: searchQuery,
  );

  @override
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to}) =>
      _datasource.watchSales(from: from, to: to);
}
