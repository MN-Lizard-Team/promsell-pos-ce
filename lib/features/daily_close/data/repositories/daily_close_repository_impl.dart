import 'dart:convert';

import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/features/daily_close/data/datasources/daily_close_local_datasource.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';

@LazySingleton(as: DailyCloseRepository)
class DailyCloseRepositoryImpl implements DailyCloseRepository {
  DailyCloseRepositoryImpl(this._datasource);

  final DailyCloseLocalDatasource _datasource;

  @override
  Future<DailyClose?> getByDate(String date) async {
    final data = await _datasource.getByDate(date);
    return data == null ? null : _toEntity(data);
  }

  @override
  Future<List<DailyClose>> getAll() async {
    final dataList = await _datasource.getAll();
    return dataList.map(_toEntity).toList();
  }

  @override
  Future<DailyClose> save(DailyClose close) async {
    final data = _toData(close);
    final saved = await _datasource.save(data);
    return _toEntity(saved);
  }

  @override
  Future<void> delete(String id) => _datasource.delete(id);

  DailyClose _toEntity(DailyCloseData data) {
    return DailyClose(
      id: data.id,
      closeDate: data.closeDate,
      openingCash: moneyFromSatangOrBaht(
        data.openingCashSatang,
        data.openingCash,
      ),
      expectedCash: moneyFromSatangOrBaht(
        data.expectedCashSatang,
        data.expectedCash,
      ),
      countedCash: moneyFromSatangOrBaht(
        data.countedCashSatang,
        data.countedCash,
      ),
      overShortAmount: moneyFromSatangOrBaht(
        data.overShortAmountSatang,
        data.overShortAmount,
      ),
      totalRevenue: moneyFromSatangOrBaht(
        data.totalRevenueSatang,
        data.totalRevenue,
      ),
      totalVoid: moneyFromSatangOrBaht(data.totalVoidSatang, data.totalVoid),
      salesCount: data.salesCount,
      voidCount: data.voidCount,
      paymentBreakdown: _parsePaymentBreakdown(data.paymentBreakdown),
      vatAmount: moneyFromSatangOrBaht(data.vatAmountSatang, data.vatAmount),
      discountAmount: moneyFromSatangOrBaht(
        data.discountAmountSatang,
        data.discountAmount,
      ),
      note: data.note,
      closedAt: data.closedAt,
      deviceId: data.deviceId,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
      version: data.version,
    );
  }

  DailyCloseData _toData(DailyClose entity) {
    return DailyCloseData(
      id: entity.id,
      closeDate: entity.closeDate,
      openingCash: entity.openingCash.value,
      expectedCash: entity.expectedCash.value,
      countedCash: entity.countedCash.value,
      overShortAmount: entity.overShortAmount.value,
      totalRevenue: entity.totalRevenue.value,
      totalVoid: entity.totalVoid.value,
      salesCount: entity.salesCount,
      voidCount: entity.voidCount,
      paymentBreakdown: jsonEncode(entity.paymentBreakdown),
      vatAmount: entity.vatAmount.value,
      discountAmount: entity.discountAmount.value,
      note: entity.note,
      closedAt: entity.closedAt,
      deviceId: entity.deviceId,
      updatedAt: entity.updatedAt ?? DateTime.now(),
      deletedAt: entity.deletedAt,
      version: entity.version,
      // Phase M (C2): dual-write satang.
      openingCashSatang: entity.openingCash,
      expectedCashSatang: entity.expectedCash,
      countedCashSatang: entity.countedCash,
      overShortAmountSatang: entity.overShortAmount,
      totalRevenueSatang: entity.totalRevenue,
      totalVoidSatang: entity.totalVoid,
      vatAmountSatang: entity.vatAmount,
      discountAmountSatang: entity.discountAmount,
    );
  }

  Map<String, double> _parsePaymentBreakdown(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (e) {
      AppLogger.warning(
        'DailyCloseRepositoryImpl._parsePaymentBreakdown failed',
        error: e,
      );
      return const {};
    }
  }
}
