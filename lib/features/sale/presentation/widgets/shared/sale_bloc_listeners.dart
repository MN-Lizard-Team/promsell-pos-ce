import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';

/// All BlocListeners for the Sale page: stock refresh, stock warning, cart
/// error, auto-save, draft error, and draft restore.
///
/// Order matters: draft restore listener must be after auto-save listener
/// so that the [_isRestoring] flag is set before auto-save fires.
class SaleBlocListeners extends StatefulWidget {
  const SaleBlocListeners({
    super.key,
    required this.productBloc,
    required this.isRestoring,
    required this.onRestoringReset,
    required this.child,
  });

  final ProductBloc productBloc;
  final ValueNotifier<bool> isRestoring;
  final VoidCallback onRestoringReset;
  final Widget child;

  @override
  State<SaleBlocListeners> createState() => _SaleBlocListenersState();
}

class _SaleBlocListenersState extends State<SaleBlocListeners> {
  bool _hasStockOrPriceChange(List<Product> prev, List<Product> curr) {
    final prevMap = {for (final p in prev) p.id: p};
    for (final c in curr) {
      final p = prevMap[c.id];
      if (p == null) return true;
      if (p.stock != c.stock ||
          p.price != c.price ||
          p.isActive != c.isActive ||
          p.name != c.name ||
          p.imagePath != c.imagePath ||
          p.imageThumbnailPath != c.imageThumbnailPath ||
          p.optionGroups.length != c.optionGroups.length) {
        return true;
      }
    }
    return prev.length != curr.length;
  }

  bool _cartSessionChanged(CartState prev, CartState curr) {
    return prev.items != curr.items ||
        prev.note != curr.note ||
        prev.cartDiscountType != curr.cartDiscountType ||
        prev.cartDiscountValue != curr.cartDiscountValue ||
        prev.orderType != curr.orderType ||
        prev.orderChannel != curr.orderChannel ||
        prev.externalOrderRef != curr.externalOrderRef ||
        prev.tableId != curr.tableId ||
        prev.serviceChargeRate != curr.serviceChargeRate ||
        prev.customerId != curr.customerId ||
        prev.promotionId != curr.promotionId ||
        prev.promotionDiscountAmount != curr.promotionDiscountAmount;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          bloc: widget.productBloc,
          listenWhen: (prev, curr) =>
              curr.status == ProductStatus.success &&
              prev.products != curr.products &&
              _hasStockOrPriceChange(prev.products, curr.products),
          listener: (context, state) {
            context.read<CartBloc>().add(CartProductsRefreshed(state.products));
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) =>
              prev.stockWarning != curr.stockWarning &&
              curr.stockWarning != null,
          listener: (context, state) {
            AppSnackBar.info(context, state.stockWarning!);
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) =>
              prev.errorNonce != curr.errorNonce && curr.errorMessage != null,
          listener: (context, state) {
            final l10n = context.l10n;
            final code = state.errorMessage;
            if (code == 'barcodeNotFound') {
              final failed = state.lastFailedBarcode;
              AppSnackBar.withAction(
                context,
                l10n.barcodeNotFound,
                actionLabel: l10n.createProductFromBarcode,
                onAction: () async {
                  final saved = await showProductCreatePage(
                    context,
                    initialBarcode: failed,
                  );
                  if (!context.mounted) return;
                  if (saved) {
                    if (failed != null && failed.isNotEmpty) {
                      context.read<CartBloc>().add(CartBarcodeScanned(failed));
                    }
                    AppSnackBar.success(
                      context,
                      l10n.productCreatedAddedToCart,
                    );
                  }
                },
              );
              return;
            }
            final msg = code == 'errorOccurred'
                ? l10n.errorOccurred
                : code == 'outOfStock'
                ? l10n.outOfStock
                : code!;
            AppSnackBar.error(context, msg);
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) => _cartSessionChanged(prev, curr),
          listener: (context, state) {
            if (widget.isRestoring.value) {
              widget.onRestoringReset();
              return;
            }
            context.read<DraftBloc>().add(DraftAutoSaveRequested(state));
          },
        ),
        BlocListener<DraftBloc, DraftState>(
          listenWhen: (prev, curr) =>
              curr.errorMessage != null &&
              curr.errorMessage != prev.errorMessage &&
              curr.lastOp != 'park' &&
              curr.lastOp != 'newBill',
          listener: (context, state) {
            final raw = state.errorMessage!;
            final l10n = context.l10n;
            String msg;
            if (raw == 'draftNotFound') {
              msg = l10n.draftNotFound;
            } else if (raw == 'paymentInProgress') {
              msg = l10n.cartPaymentInProgress;
            } else if (raw == 'tableAlreadyBound') {
              msg = l10n.tableAlreadyBound;
            } else if (raw.startsWith('maxDraftsReached:')) {
              final n = int.tryParse(raw.split(':').last) ?? 0;
              msg = l10n.maxDraftsReached(n);
            } else {
              msg = l10n.errorOccurred;
            }
            AppSnackBar.error(context, msg);
          },
        ),
        BlocListener<DraftBloc, DraftState>(
          listenWhen: (prev, curr) =>
              curr.loadedDraft != null && prev.loadedDraft != curr.loadedDraft,
          listener: (context, state) {
            widget.isRestoring.value = true;
            final draft = state.loadedDraft!;
            context.read<CartBloc>().add(
              CartRestored(
                items: draft.items,
                note: draft.note ?? '',
                cartDiscountType: draft.cartDiscountType,
                cartDiscountValue: draft.cartDiscountValue,
                orderType: draft.orderType,
                orderChannel: draft.orderChannel,
                externalOrderRef: draft.externalOrderRef,
                tableId: draft.tableId,
                serviceChargeRate: draft.serviceChargeRate,
                customerId: draft.customerId,
                promotionId: draft.promotionId,
                promotionDiscountAmount: draft.promotionDiscountAmount.value,
                guestCount: draft.guestCount,
                openedAt: draft.openedAt,
              ),
            );
            if (draft.skippedItemCount > 0 && context.mounted) {
              AppSnackBar.info(
                context,
                context.l10n.billItemsMissing(draft.skippedItemCount),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onRestoringReset();
            });
          },
        ),
      ],
      child: widget.child,
    );
  }
}
