import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_product_detail_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/bill_note_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Shared cart line mutations for full-page review and docked panel.
///
/// Keeps stock clamps / undo / detail sheet in one place (parity).
abstract final class CartLineActions {
  CartLineActions._();

  /// True while cart mutations must freeze.
  ///
  /// Parity with [DraftBillSwitchGuard]: `paymentLocked` **or** checkout
  /// [CheckoutStatus.waitingPayment] / [CheckoutStatus.processing].
  static bool isPaymentLocked(BuildContext context) {
    try {
      final cartLocked = context.read<CartBloc>().state.paymentLocked;
      if (cartLocked) return true;
      final status = context.read<CheckoutBloc>().state.status;
      return status == CheckoutStatus.waitingPayment ||
          status == CheckoutStatus.processing;
    } catch (_) {
      try {
        return context.read<CartBloc>().state.paymentLocked;
      } catch (_) {
        return false;
      }
    }
  }

  static Widget paymentLockBanner(BuildContext context) {
    if (!isPaymentLocked(context)) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      key: const ValueKey('sale_cart_payment_lock_banner'),
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.lock_outline, color: scheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.cartPaymentInProgress,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onErrorContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showImage(BuildContext context, CartItem item) async {
    final provider = await ImageViewerDialog.providerFromPathsAsync(
      imagePath: item.product.imagePath,
      imageUrl: item.product.imageUrl,
    );
    // ignore: use_build_context_synchronously
    ImageViewerDialog.showSingle(context, provider);
  }

  static void changeQty(BuildContext context, CartItem item, int delta) {
    if (item.qty == 1 && delta == -1) {
      removeItem(context, item);
      return;
    }
    final allowOversell = context
        .read<SettingsCubit>()
        .state
        .settings
        .allowOversell;
    final cart = context.read<CartBloc>().state;
    final otherQty = cart.items
        .where(
          (i) => i.product.id == item.product.id && i.lineId != item.lineId,
        )
        .fold<int>(0, (s, i) => s + i.qty);
    final maxQty = item.product.trackStock && !allowOversell
        ? (item.product.stock - otherQty).clamp(0, 9999)
        : 9999;
    final newQty = (item.qty + delta).clamp(1, maxQty);
    if (newQty != item.qty) {
      HapticFeedback.selectionClick();
      context.read<CartBloc>().add(
        CartItemQtyChanged(
          productId: item.product.id,
          qty: newQty,
          lineId: item.lineId,
          allowOversell: allowOversell,
        ),
      );
    }
  }

  static void removeItem(BuildContext context, CartItem item) {
    HapticFeedback.mediumImpact();
    context.read<CartBloc>().add(
      CartProductRemoved(item.product.id, lineId: item.lineId),
    );
    AppSnackBar.withAction(
      context,
      context.l10n.itemRemoved(item.product.name),
      actionLabel: context.l10n.undo,
      onAction: () => context.read<CartBloc>().add(CartItemRestored(item)),
    );
  }

  static void showItemDiscount(BuildContext context, CartItem item) {
    final settings = context.read<SettingsCubit>().state.settings;
    DiscountDialog.showItemDiscount(
      context,
      title: item.product.name,
      currency: settings.currency,
      initialType: item.discountType ?? settings.defaultDiscountType,
      initialValue: item.discountValue,
      maxPercent: settings.maxDiscountPercent,
      maxAmount: settings.maxDiscountAmount.value,
      presetValues: settings.activeDiscountPreset.values,
      presetType: settings.activeDiscountPreset.type,
      onApply: (type, value) => context.read<CartBloc>().add(
        CartItemDiscountChanged(
          productId: item.product.id,
          lineId: item.lineId,
          discountType: type,
          discountValue: value,
        ),
      ),
      onClear: () => context.read<CartBloc>().add(
        CartItemDiscountCleared(item.product.id, lineId: item.lineId),
      ),
    );
  }

  static void showItemNote(BuildContext context, CartItem item) {
    final cartBloc = context.read<CartBloc>();
    BillNoteSheet.showItemNote(
      context,
      productName: item.product.name,
      initialValue: item.note ?? '',
      onSave: (note) {
        cartBloc.add(
          CartItemNoteChanged(
            productId: item.product.id,
            lineId: item.lineId,
            note: note.isEmpty ? null : note,
          ),
        );
      },
    );
  }

  static void duplicateItem(BuildContext context, CartItem item) {
    context.read<CartBloc>().add(CartItemDuplicated(item));
    AppSnackBar.success(context, context.l10n.duplicateItem);
  }

  static void openDetail(BuildContext context, CartItem item) {
    final enableItemDiscount = context
        .read<SettingsCubit>()
        .state
        .settings
        .enableItemDiscount;
    CartProductDetailSheet.show(
      context,
      item,
      onEditNote: () => showItemNote(context, item),
      onEditDiscount: enableItemDiscount
          ? () => showItemDiscount(context, item)
          : null,
    );
  }
}
