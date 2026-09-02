import 'package:promsell_pos_ce/features/sale/domain/entities/cart_snapshot.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

/// Pure mapping from [CartState] (presentation state) to [CartSnapshot]
/// (persistence DTO).
///
/// Extracted from `draft_bloc.dart` to keep the BLoC focused on event
/// orchestration rather than mapping logic.
CartSnapshot cartStateToSnapshot(CartState s) => CartSnapshot(
  items: s.items,
  note: s.note,
  cartDiscountType: s.cartDiscountType,
  cartDiscountValue: s.cartDiscountValue,
  orderType: s.orderType,
  orderChannel: s.orderChannel,
  externalOrderRef: s.externalOrderRef,
  tableId: s.tableId,
  serviceChargeRate: s.serviceChargeRate,
  customerId: s.customerId,
  promotionId: s.promotionId,
  promotionDiscountAmount: s.promotionDiscountAmount,
  guestCount: s.guestCount,
  openedAt: s.openedAt,
);
