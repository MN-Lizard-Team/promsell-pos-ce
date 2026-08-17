import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

@injectable
class GetReportSummary {
  const GetReportSummary(this._saleRepository);
  final SaleRepository _saleRepository;

  Future<ReportSummary> call({DateTime? from, DateTime? to}) =>
      _saleRepository.getReportSummary(from: from, to: to);
}
