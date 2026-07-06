import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

enum PromotionStatus { initial, loading, success, failure }

enum PromotionSaveStatus { idle, saving, saved, error }

class PromotionState extends Equatable {
  const PromotionState({
    this.status = PromotionStatus.initial,
    this.promotions = const [],
    this.searchQuery = '',
    this.errorMessage,
    this.saveStatus = PromotionSaveStatus.idle,
  });

  final PromotionStatus status;
  final List<Promotion> promotions;
  final String searchQuery;
  final String? errorMessage;
  final PromotionSaveStatus saveStatus;

  List<Promotion> get filtered {
    if (searchQuery.isEmpty) return promotions;
    final q = searchQuery.toLowerCase();
    return promotions.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  List<Promotion> get activePromotions =>
      promotions.where((p) => p.isCurrentlyActive).toList();

  PromotionState copyWith({
    PromotionStatus? status,
    List<Promotion>? promotions,
    String? searchQuery,
    String? errorMessage,
    PromotionSaveStatus? saveStatus,
  }) {
    return PromotionState(
      status: status ?? this.status,
      promotions: promotions ?? this.promotions,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }

  @override
  List<Object?> get props => [
    status,
    promotions,
    searchQuery,
    errorMessage,
    saveStatus,
  ];
}
