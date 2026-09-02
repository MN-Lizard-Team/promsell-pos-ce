import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

abstract class DraftEvent extends Equatable {
  const DraftEvent();
  @override
  List<Object?> get props => [];
}

class DraftInitialized extends DraftEvent {
  const DraftInitialized();
}

class DraftFireRequested extends DraftEvent {
  const DraftFireRequested({this.cartId});
  final String? cartId;

  @override
  List<Object?> get props => [cartId];
}

class DraftTransferRequested extends DraftEvent {
  const DraftTransferRequested({
    required this.sourceTableId,
    required this.targetTableId,
  });
  final String sourceTableId;
  final String targetTableId;
  @override
  List<Object?> get props => [sourceTableId, targetTableId];
}

class DraftSwitched extends DraftEvent {
  const DraftSwitched(
    this.draftId, {
    this.paymentLocked = false,
    this.liveCart,
  });
  final String draftId;

  /// When true, bloc rejects switch (cart frozen mid-checkout).
  final bool paymentLocked;

  /// Live cart to **force-save** onto the current active draft before loading
  /// [draftId]. Prevents losing edits still inside the autosave debounce window.
  final CartState? liveCart;

  @override
  List<Object?> get props => [draftId, paymentLocked, liveCart];
}

class DraftCreated extends DraftEvent {
  const DraftCreated({this.name});
  final String? name;
  @override
  List<Object?> get props => [name];
}

class DraftDeleted extends DraftEvent {
  const DraftDeleted(this.draftId, {this.paymentLocked = false});
  final String draftId;

  /// When true, bloc rejects delete (cart frozen mid-checkout).
  final bool paymentLocked;

  @override
  List<Object?> get props => [draftId, paymentLocked];
}

class DraftRenamed extends DraftEvent {
  const DraftRenamed({
    required this.draftId,
    required this.name,
    this.paymentLocked = false,
  });
  final String draftId;
  final String name;

  /// When true, bloc rejects rename mid-payment.
  final bool paymentLocked;

  @override
  List<Object?> get props => [draftId, name, paymentLocked];
}

/// Recompute [DraftState.draftCount] / [DraftState.openBillCount] from DB.
class DraftCountsRefreshRequested extends DraftEvent {
  const DraftCountsRefreshRequested();
}

class DraftAutoSaveRequested extends DraftEvent {
  const DraftAutoSaveRequested(this.cartState);
  final CartState cartState;
  @override
  List<Object?> get props => [cartState];
}

/// Post-checkout rotation: the SOLD draft cart was already deleted inside the
/// sale transaction ([SaleInsertWriter]); this event only fixes active
/// pointers / counters / UI state.
///
/// [soldDraftId] is the originating draft cart id captured at checkout
/// freeze. When it equals the active draft, a fresh empty bill is created and
/// activated; when it differs (draft switched mid-payment) pointers are left
/// untouched. Null (never-parked ephemeral cart) only refreshes counters.
class DraftRotated extends DraftEvent {
  const DraftRotated({this.soldDraftId});
  final String? soldDraftId;
  @override
  List<Object?> get props => [soldDraftId];
}

/// Immediate persist of [cartState] to the active draft (no debounce).
class DraftForceSaveRequested extends DraftEvent {
  const DraftForceSaveRequested(this.cartState);
  final CartState cartState;
  @override
  List<Object?> get props => [cartState];
}

/// Park current bill: force-save active draft then create a new empty draft.
///
/// Name policy on the **parked** draft (via [DraftNaming.resolveParkName]):
/// - [name] non-null (long-press / explicit): trim, or auto if empty
/// - [name] null (1-tap): keep existing active name if set; else auto
///
/// New empty draft always gets [DraftNaming.forNewEmptyBill].
/// Does not clear cart — UI clears only after success.
class DraftParkRequested extends DraftEvent {
  const DraftParkRequested(this.cartState, {this.name});
  final CartState cartState;

  /// When non-null, treated as explicit name intent (even if empty string).
  final String? name;
  @override
  List<Object?> get props => [cartState, name];
}

/// Start a new bill: force-save current, create empty draft.
/// Does not clear cart — UI clears only after success.
class DraftStartNewBillRequested extends DraftEvent {
  const DraftStartNewBillRequested(this.cartState, {this.name});
  final CartState cartState;
  final String? name;
  @override
  List<Object?> get props => [cartState, name];
}

/// A debounced/flushed autosave hit a business-rule rejection (e.g. the table
/// is already bound by another active bill). [messageKey] is the stable UI
/// key resolved by `DraftBloc._errorMessageOf`, not a raw exception string.
class DraftAutosaveFailed extends DraftEvent {
  const DraftAutosaveFailed(this.messageKey);
  final String messageKey;
  @override
  List<Object?> get props => [messageKey];
}
