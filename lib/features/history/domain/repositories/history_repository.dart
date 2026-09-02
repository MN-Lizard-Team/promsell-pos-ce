import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';
import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

abstract class HistoryRepository {
  Future<List<Sale>> getSales({DateTime? from, DateTime? to});
  Future<SalePage> getSalesPage({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
    String? searchQuery,
  });
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
}
