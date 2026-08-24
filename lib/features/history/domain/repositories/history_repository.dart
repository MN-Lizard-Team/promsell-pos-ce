import 'package:promsell_pos_ce/shared/domain/entities/sale.dart';

abstract class HistoryRepository {
  Future<List<Sale>> getSales({DateTime? from, DateTime? to});
  Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
}
