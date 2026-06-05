import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
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
      openingCash: data.openingCash,
      expectedCash: data.expectedCash,
      countedCash: data.countedCash,
      overShortAmount: data.overShortAmount,
      totalRevenue: data.totalRevenue,
      totalVoid: data.totalVoid,
      salesCount: data.salesCount,
      voidCount: data.voidCount,
      paymentBreakdown: _parsePaymentBreakdown(data.paymentBreakdown),
      vatAmount: data.vatAmount,
      discountAmount: data.discountAmount,
      note: data.note,
      closedAt: data.closedAt,
      deviceId: data.deviceId,
    );
  }

  DailyCloseData _toData(DailyClose entity) {
    return DailyCloseData(
      id: entity.id,
      closeDate: entity.closeDate,
      openingCash: entity.openingCash,
      expectedCash: entity.expectedCash,
      countedCash: entity.countedCash,
      overShortAmount: entity.overShortAmount,
      totalRevenue: entity.totalRevenue,
      totalVoid: entity.totalVoid,
      salesCount: entity.salesCount,
      voidCount: entity.voidCount,
      paymentBreakdown: jsonEncode(entity.paymentBreakdown),
      vatAmount: entity.vatAmount,
      discountAmount: entity.discountAmount,
      note: entity.note,
      closedAt: entity.closedAt,
      deviceId: entity.deviceId,
    );
  }

  Map<String, double> _parsePaymentBreakdown(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return const {};
    }
  }
}
