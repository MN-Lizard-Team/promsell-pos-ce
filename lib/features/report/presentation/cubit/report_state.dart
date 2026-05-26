import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  const ReportState({
    this.status = ReportStatus.initial,
    this.sales = const [],
    this.from,
    this.to,
  });

  final ReportStatus status;
  final List<Sale> sales;
  final DateTime? from;
  final DateTime? to;

  bool get isLoading => status == ReportStatus.loading;
  bool get hasError => status == ReportStatus.failure;

  ReportState copyWith({
    ReportStatus? status,
    List<Sale>? sales,
    DateTime? from,
    DateTime? to,
  }) {
    return ReportState(
      status: status ?? this.status,
      sales: sales ?? this.sales,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  @override
  List<Object?> get props => [status, sales, from, to];
}
