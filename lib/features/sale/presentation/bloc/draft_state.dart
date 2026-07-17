import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';

const Object _unset = Object();

enum DraftOpStatus { idle, saving, success, failure }

class DraftState extends Equatable {
  const DraftState({
    this.activeDraftId,
    this.activeDraftName,
    this.errorMessage,
    this.loadedDraft,
    this.draftCount = 0,
    this.openBillCount = 0,
    this.opStatus = DraftOpStatus.idle,
    this.opNonce = 0,
    this.lastOp,
  });

  final String? activeDraftId;
  final String? activeDraftName;
  final String? errorMessage;
  final DraftCart? loadedDraft;
  final int draftCount;

  /// Drafts with at least one line item (badge / open-bills chip).
  final int openBillCount;

  /// Terminal ops bump [opNonce] so UI can await completion.
  final DraftOpStatus opStatus;
  final int opNonce;

  /// park | newBill | forceSave | null
  final String? lastOp;

  bool get isBusy => opStatus == DraftOpStatus.saving;

  DraftState copyWith({
    Object? activeDraftId = _unset,
    Object? activeDraftName = _unset,
    Object? errorMessage = _unset,
    Object? loadedDraft = _unset,
    int? draftCount,
    int? openBillCount,
    DraftOpStatus? opStatus,
    int? opNonce,
    Object? lastOp = _unset,
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
    draftCount: draftCount ?? this.draftCount,
    openBillCount: openBillCount ?? this.openBillCount,
    opStatus: opStatus ?? this.opStatus,
    opNonce: opNonce ?? this.opNonce,
    lastOp: identical(lastOp, _unset) ? this.lastOp : lastOp as String?,
  );

  @override
  List<Object?> get props => [
    activeDraftId,
    activeDraftName,
    errorMessage,
    loadedDraft,
    draftCount,
    openBillCount,
    opStatus,
    opNonce,
    lastOp,
  ];
}
