import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

abstract class PromotionRepository {
  Future<List<Promotion>> getAllPromotions();
  Future<List<Promotion>> getActivePromotions();
  Stream<List<Promotion>> watchAllPromotions();
  Future<Promotion?> getPromotionById(String id);
  Future<String> addPromotion(Promotion promotion);
  Future<void> updatePromotion(Promotion promotion);
  Future<void> deletePromotion(String id);
}
