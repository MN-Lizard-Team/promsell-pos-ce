import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/report/domain/repositories/report_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

@injectable
class WatchReport {
  const WatchReport(this._repository);
  final ReportRepository _repository;

  Stream<List<Sale>> call({DateTime? from, DateTime? to}) =>
      _repository.watchSales(from: from, to: to);
}
