import 'package:promsell_pos_ce/features/report/domain/repositories/report_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

class GetReport {
  const GetReport(this._repository);
  final ReportRepository _repository;

  Future<List<Sale>> call({DateTime? from, DateTime? to}) =>
      _repository.getSales(from: from, to: to);
}
