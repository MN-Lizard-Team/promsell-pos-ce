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

class DraftSwitched extends DraftEvent {
  const DraftSwitched(this.draftId);
  final String draftId;
  @override
  List<Object?> get props => [draftId];
}

class DraftCreated extends DraftEvent {
  const DraftCreated({this.name});
  final String? name;
  @override
  List<Object?> get props => [name];
}

class DraftDeleted extends DraftEvent {
  const DraftDeleted(this.draftId);
  final String draftId;
  @override
  List<Object?> get props => [draftId];
}

class DraftRenamed extends DraftEvent {
  const DraftRenamed({required this.draftId, required this.name});
  final String draftId;
  final String name;
  @override
  List<Object?> get props => [draftId, name];
}

class DraftAutoSaveRequested extends DraftEvent {
  const DraftAutoSaveRequested(this.cartState);
  final CartState cartState;
  @override
  List<Object?> get props => [cartState];
}

class DraftRotated extends DraftEvent {
  const DraftRotated();
}
