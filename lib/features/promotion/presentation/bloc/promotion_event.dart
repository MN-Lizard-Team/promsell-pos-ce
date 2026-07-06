import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

abstract class PromotionEvent extends Equatable {
  const PromotionEvent();
  @override
  List<Object?> get props => [];
}

class PromotionsSubscribed extends PromotionEvent {
  const PromotionsSubscribed();
}

class PromotionAdded extends PromotionEvent {
  const PromotionAdded(this.promotion);
  final Promotion promotion;

  @override
  List<Object?> get props => [promotion];
}

class PromotionUpdated extends PromotionEvent {
  const PromotionUpdated(this.promotion);
  final Promotion promotion;

  @override
  List<Object?> get props => [promotion];
}

class PromotionDeleted extends PromotionEvent {
  const PromotionDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

class PromotionSearchChanged extends PromotionEvent {
  const PromotionSearchChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}
