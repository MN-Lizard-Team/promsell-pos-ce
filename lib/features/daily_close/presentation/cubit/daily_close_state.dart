part of 'daily_close_cubit.dart';

enum DailyCloseStatus {
  initial,
  loading,
  calculating,
  ready,
  closing,
  closed,
  reopening,
  reopened,
  error,
}

class DailyCloseState extends Equatable {
  const DailyCloseState({
    this.status = DailyCloseStatus.initial,
    this.date,
    this.dailyClose,
    this.salesSummary,
    this.countedCash = 0,
    this.openingCash = 0,
    this.note = '',
    this.errorMessage,
  });

  final DailyCloseStatus status;
  final String? date;
  final DailyClose? dailyClose;
  final SalesSummary? salesSummary;
  final double countedCash;
  final double openingCash;
  final String note;
  final String? errorMessage;

  bool get isClosed => dailyClose?.isClosed ?? false;
  double get overShort => countedCash - (salesSummary?.expectedCash ?? 0);

  DailyCloseState copyWith({
    DailyCloseStatus? status,
    String? date,
    DailyClose? dailyClose,
    SalesSummary? salesSummary,
    double? countedCash,
    double? openingCash,
    String? note,
    String? errorMessage,
  }) {
    return DailyCloseState(
      status: status ?? this.status,
      date: date ?? this.date,
      dailyClose: dailyClose ?? this.dailyClose,
      salesSummary: salesSummary ?? this.salesSummary,
      countedCash: countedCash ?? this.countedCash,
      openingCash: openingCash ?? this.openingCash,
      note: note ?? this.note,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    date,
    dailyClose,
    salesSummary,
    countedCash,
    openingCash,
    note,
    errorMessage,
  ];
}

class SalesSummary {
  const SalesSummary({
    required this.salesCount,
    required this.voidCount,
    required this.grossRevenue,
    required this.voidedAmount,
    required this.netRevenue,
    required this.paymentBreakdown,
    required this.vatAmount,
    required this.discountAmount,
    required this.expectedCash,
  });

  final int salesCount;
  final int voidCount;
  final double grossRevenue;
  final double voidedAmount;
  final double netRevenue;
  final Map<String, double> paymentBreakdown;
  final double vatAmount;
  final double discountAmount;
  final double expectedCash;
}
