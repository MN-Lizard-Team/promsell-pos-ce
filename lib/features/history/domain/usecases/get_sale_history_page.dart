import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/history/domain/repositories/history_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';

@injectable
class GetSaleHistoryPage {
  const GetSaleHistoryPage(this._repository);

  final HistoryRepository _repository;

  Future<SalePage> call({
    DateTime? from,
    DateTime? to,
    SaleCursor? cursor,
    int pageSize = 50,
    String? searchQuery,
  }) => _repository.getSalesPage(
    from: from,
    to: to,
    cursor: cursor,
    pageSize: pageSize,
    searchQuery: searchQuery,
  );
}
