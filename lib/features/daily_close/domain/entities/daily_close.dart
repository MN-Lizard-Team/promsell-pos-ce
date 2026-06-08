import 'package:equatable/equatable.dart';

const _unset = Object();

class DailyClose extends Equatable {
  const DailyClose({
    required this.id,
    required this.closeDate,
    this.openingCash = 0,
    this.expectedCash = 0,
    this.countedCash = 0,
    this.overShortAmount = 0,
    this.totalRevenue = 0,
    this.totalVoid = 0,
    this.salesCount = 0,
    this.voidCount = 0,
    this.paymentBreakdown = const {},
    this.vatAmount = 0,
    this.discountAmount = 0,
    this.note,
    this.closedAt,
    this.deviceId,
    this.updatedAt,
    this.deletedAt,
    this.version = 1,
  });

  final String id;
  final String closeDate;
  final double openingCash;
  final double expectedCash;
  final double countedCash;
  final double overShortAmount;
  final double totalRevenue;
  final double totalVoid;
  final int salesCount;
  final int voidCount;
  final Map<String, double> paymentBreakdown;
  final double vatAmount;
  final double discountAmount;
  final String? note;
  final DateTime? closedAt;
  final String? deviceId;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final int version;

  bool get isClosed => closedAt != null;

  DailyClose copyWith({
    String? id,
    String? closeDate,
    double? openingCash,
    double? expectedCash,
    double? countedCash,
    double? overShortAmount,
    double? totalRevenue,
    double? totalVoid,
    int? salesCount,
    int? voidCount,
    Map<String, double>? paymentBreakdown,
    double? vatAmount,
    double? discountAmount,
    Object? note = _unset,
    Object? closedAt = _unset,
    Object? deviceId = _unset,
    Object? updatedAt = _unset,
    Object? deletedAt = _unset,
    int? version,
  }) {
    return DailyClose(
      id: id ?? this.id,
      closeDate: closeDate ?? this.closeDate,
      openingCash: openingCash ?? this.openingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      countedCash: countedCash ?? this.countedCash,
      overShortAmount: overShortAmount ?? this.overShortAmount,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalVoid: totalVoid ?? this.totalVoid,
      salesCount: salesCount ?? this.salesCount,
      voidCount: voidCount ?? this.voidCount,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
      vatAmount: vatAmount ?? this.vatAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      note: identical(note, _unset) ? this.note : note as String?,
      closedAt: identical(closedAt, _unset)
          ? this.closedAt
          : closedAt as DateTime?,
      deviceId: identical(deviceId, _unset)
          ? this.deviceId
          : deviceId as String?,
      updatedAt: identical(updatedAt, _unset)
          ? this.updatedAt
          : updatedAt as DateTime?,
      deletedAt: identical(deletedAt, _unset)
          ? this.deletedAt
          : deletedAt as DateTime?,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
    id,
    closeDate,
    openingCash,
    expectedCash,
    countedCash,
    overShortAmount,
    totalRevenue,
    totalVoid,
    salesCount,
    voidCount,
    paymentBreakdown,
    vatAmount,
    discountAmount,
    note,
    closedAt,
    deviceId,
    updatedAt,
    deletedAt,
    version,
  ];
}
