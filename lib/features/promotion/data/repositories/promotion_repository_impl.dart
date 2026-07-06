import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/promotion/data/datasources/promotion_datasource.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/promotion/domain/repositories/promotion_repository.dart';

@LazySingleton(as: PromotionRepository)
class PromotionRepositoryImpl implements PromotionRepository {
  const PromotionRepositoryImpl(this._datasource);
  final PromotionDatasource _datasource;

  @override
  Future<List<Promotion>> getAllPromotions() => _datasource.getAll();

  @override
  Future<List<Promotion>> getActivePromotions() => _datasource.getActive();

  @override
  Stream<List<Promotion>> watchAllPromotions() => _datasource.watchAll();

  @override
  Future<Promotion?> getPromotionById(String id) => _datasource.getById(id);

  @override
  Future<String> addPromotion(Promotion promotion) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _datasource.insert(
      PromotionsCompanion.insert(
        id: id,
        name: promotion.name,
        type: Value(
          promotion.type == PromotionType.amount ? 'AMOUNT' : 'PERCENT',
        ),
        value: Value(promotion.value),
        minPurchaseAmount: Value(promotion.minPurchaseAmount),
        startDate: Value(promotion.startDate),
        endDate: Value(promotion.endDate),
        isActive: Value(promotion.isActive),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    return id;
  }

  @override
  Future<void> updatePromotion(Promotion promotion) async {
    await _datasource.update(
      PromotionsCompanion(
        id: Value(promotion.id),
        name: Value(promotion.name),
        type: Value(
          promotion.type == PromotionType.amount ? 'AMOUNT' : 'PERCENT',
        ),
        value: Value(promotion.value),
        minPurchaseAmount: Value(promotion.minPurchaseAmount),
        startDate: Value(promotion.startDate),
        endDate: Value(promotion.endDate),
        isActive: Value(promotion.isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deletePromotion(String id) => _datasource.softDelete(id);
}
