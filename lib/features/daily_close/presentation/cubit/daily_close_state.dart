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
    this.preview,
    this.countedCash = 0,
    this.openingCash = 0,
    this.note = '',
    this.errorMessage,
  });

  final DailyCloseStatus status;
  final String? date;
  final DailyClose? dailyClose;
  final DailyClosePreview? preview;
  final double countedCash;
  final double openingCash;
  final String note;
  final String? errorMessage;

  bool get isClosed => dailyClose?.isClosed ?? false;
  double get expectedCash => isClosed
      ? dailyClose!.expectedCash.value
      : openingCash + (preview?.cashSales.value ?? 0);
  double get overShort =>
      isClosed ? dailyClose!.overShortAmount.value : countedCash - expectedCash;

  DailyCloseState copyWith({
    DailyCloseStatus? status,
    String? date,
    DailyClose? dailyClose,
    bool clearDailyClose = false,
    DailyClosePreview? preview,
    bool clearPreview = false,
    double? countedCash,
    double? openingCash,
    String? note,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DailyCloseState(
      status: status ?? this.status,
      date: date ?? this.date,
      dailyClose: clearDailyClose ? null : dailyClose ?? this.dailyClose,
      preview: clearPreview ? null : preview ?? this.preview,
      countedCash: countedCash ?? this.countedCash,
      openingCash: openingCash ?? this.openingCash,
      note: note ?? this.note,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    date,
    dailyClose,
    preview,
    countedCash,
    openingCash,
    note,
    errorMessage,
  ];
}
