import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/database/money_converter.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

abstract class PromotionDatasource {
  Future<List<Promotion>> getAll();
  Future<List<Promotion>> getActive();
  Stream<List<Promotion>> watchAll();
  Future<Promotion?> getById(String id);
  Future<void> insert(PromotionsCompanion companion);
  Future<void> update(PromotionsCompanion companion);
  Future<void> softDelete(String id);
}

@LazySingleton(as: PromotionDatasource)
class PromotionDatasourceImpl implements PromotionDatasource {
  const PromotionDatasourceImpl(this._db);
  final AppDatabase _db;

  Promotion _fromData(PromotionData d) => Promotion(
    id: d.id,
    name: d.name,
    type: d.type == 'AMOUNT' ? PromotionType.amount : PromotionType.percent,
    value: d.valueSatang?.value ?? d.value,
    minPurchaseAmount: moneyFromSatangOrBaht(
      d.minPurchaseAmountSatang,
      d.minPurchaseAmount,
    ),
    startDate: d.startDate,
    endDate: d.endDate,
    isActive: d.isActive,
    createdAt: d.createdAt,
    updatedAt: d.updatedAt,
  );

  @override
  Future<List<Promotion>> getAll() =>
      (_db.select(_db.promotions)
            ..where((p) => p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .get()
          .then((rows) => rows.map(_fromData).toList());

  @override
  Future<List<Promotion>> getActive() {
    final now = DateTime.now();
    return (_db.select(_db.promotions)
          ..where((p) => p.deletedAt.isNull())
          ..where((p) => p.isActive.equals(true))
          ..where((p) => p.startDate.isSmallerOrEqualValue(now))
          ..where(
            (p) => p.endDate.isNull() | p.endDate.isBiggerOrEqualValue(now),
          )
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
        .get()
        .then((rows) => rows.map(_fromData).toList());
  }

  @override
  Stream<List<Promotion>> watchAll() =>
      (_db.select(_db.promotions)
            ..where((p) => p.deletedAt.isNull())
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch()
          .map((rows) => rows.map(_fromData).toList());

  @override
  Future<Promotion?> getById(String id) =>
      (_db.select(_db.promotions)
            ..where((p) => p.id.equals(id))
            ..where((p) => p.deletedAt.isNull()))
          .getSingleOrNull()
          .then((d) => d == null ? null : _fromData(d));

  @override
  Future<void> insert(PromotionsCompanion companion) =>
      _db.into(_db.promotions).insert(companion);

  @override
  Future<void> update(PromotionsCompanion companion) => (_db.update(
    _db.promotions,
  )..where((p) => p.id.equals(companion.id.value))).write(companion);

  @override
  Future<void> softDelete(String id) =>
      (_db.update(_db.promotions)..where((p) => p.id.equals(id))).write(
        PromotionsCompanion(deletedAt: Value(DateTime.now())),
      );
}
