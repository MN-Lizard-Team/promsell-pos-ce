import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';

const Object _unset = Object();

class DraftState extends Equatable {
  const DraftState({
    this.activeDraftId,
    this.activeDraftName,
    this.errorMessage,
    this.loadedDraft,
  });

  final String? activeDraftId;
  final String? activeDraftName;
  final String? errorMessage;
  final DraftCart? loadedDraft;

  DraftState copyWith({
    Object? activeDraftId = _unset,
    Object? activeDraftName = _unset,
    Object? errorMessage = _unset,
    Object? loadedDraft = _unset,
  }) => DraftState(
    activeDraftId: identical(activeDraftId, _unset)
        ? this.activeDraftId
        : activeDraftId as String?,
    activeDraftName: identical(activeDraftName, _unset)
        ? this.activeDraftName
        : activeDraftName as String?,
    errorMessage: identical(errorMessage, _unset)
        ? this.errorMessage
        : errorMessage as String?,
    loadedDraft: identical(loadedDraft, _unset)
        ? this.loadedDraft
        : loadedDraft as DraftCart?,
  );

  @override
  List<Object?> get props => [
    activeDraftId,
    activeDraftName,
    errorMessage,
    loadedDraft,
  ];
}
