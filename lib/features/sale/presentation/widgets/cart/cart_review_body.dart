import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/bill_meta_chip_strip.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_product_detail_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_footer.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/saved_bills_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

enum CartMenuAction { drafts, discount, clear }

/// Bill lines + meta chips + settle dock (full-page review).
class CartReviewBody extends StatelessWidget {
  const CartReviewBody({super.key});

  void _showImageDialog(BuildContext context, CartItem item) {
    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: item.product.imagePath,
        imageUrl: item.product.imageUrl,
      ),
    );
  }

  void _changeQty(BuildContext context, CartItem item, int delta) {
    if (item.qty == 1 && delta == -1) {
      _removeItem(context, item);
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

  void _removeItem(BuildContext context, CartItem item) {
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

  static void showCartDiscount(BuildContext context, CartState state) {
    final settings = context.read<SettingsCubit>().state.settings;
    DiscountDialog.showCartDiscount(
      context,
      title: context.l10n.cartDiscount,
      currency: settings.currency,
      initialType: state.cartDiscountType ?? settings.defaultDiscountType,
      initialValue: state.cartDiscountValue,
      maxPercent: settings.maxDiscountPercent,
      maxAmount: settings.maxDiscountAmount.value,
      presetValues: settings.activeDiscountPreset.values,
      presetType: settings.activeDiscountPreset.type,
      onApply: (type, value) => context.read<CartBloc>().add(
        CartDiscountChanged(discountType: type, discountValue: value),
      ),
      onClear: () => context.read<CartBloc>().add(const CartDiscountCleared()),
    );
  }

  void _showItemDiscount(BuildContext context, CartItem item) {
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

  void _showItemNote(BuildContext context, CartItem item) {
    final l10n = context.l10n;
    final cartBloc = context.read<CartBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => _CartTextNoteDialog(
        title: l10n.itemNoteLabel,
        initialValue: item.note ?? '',
        labelText: item.product.name,
        hintText: null,
        cancelLabel: l10n.cancel,
        saveLabel: l10n.save,
        onSave: (note) {
          cartBloc.add(
            CartItemNoteChanged(
              productId: item.product.id,
              lineId: item.lineId,
              note: note.isEmpty ? null : note,
            ),
          );
        },
      ),
    );
  }

  static void showCartNote(BuildContext context, CartState state) {
    final l10n = context.l10n;
    final cartBloc = context.read<CartBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => _CartTextNoteDialog(
        title: l10n.saleBillNoteTitle,
        initialValue: state.note,
        labelText: null,
        hintText: l10n.notePlaceholder,
        cancelLabel: l10n.cancel,
        saveLabel: l10n.save,
        onSave: (note) => cartBloc.add(CartNoteChanged(note)),
      ),
    );
  }

  void _duplicateItem(BuildContext context, CartItem item) {
    context.read<CartBloc>().add(CartItemDuplicated(item));
    AppSnackBar.success(context, context.l10n.duplicateItem);
  }

  static Future<void> clearCart(BuildContext context, CartState state) async {
    if (state.isEmpty) return;
    final confirmed = await showConfirmationDialog(
      context,
      title: context.l10n.clearCart,
      message: context.l10n.confirmClearCart,
      confirmLabel: context.l10n.clearCart,
      cancelLabel: context.l10n.cancel,
      destructive: true,
      confirmIcon: Icons.remove_shopping_cart_outlined,
    );
    if (!confirmed || !context.mounted) return;
    final restore = CartRestored.fromCartState(state);
    context.read<CartBloc>().add(const CartCleared());
    AppSnackBar.withAction(
      context,
      context.l10n.clearCart,
      actionLabel: context.l10n.undo,
      onAction: () => context.read<CartBloc>().add(restore),
    );
  }

  static void handleMenuAction(
    BuildContext context,
    CartMenuAction action,
    CartState state,
  ) {
    switch (action) {
      case CartMenuAction.drafts:
        SavedBillsPage.open(context);
      case CartMenuAction.discount:
        showCartDiscount(context, state);
      case CartMenuAction.clear:
        clearCart(context, state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocBuilder<CartBloc, CartState>(
      builder: (_, state) {
        final items = state.items;

        final paymentLocked = _isPaymentLocked(context);

        return Column(
          children: [
            Builder(
              builder: (context) {
                try {
                  final checkout = context.watch<CheckoutBloc>().state;
                  if (checkout.status != CheckoutStatus.waitingPayment) {
                    return const SizedBox.shrink();
                  }
                  final theme = Theme.of(context);
                  return Material(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.55,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.cartPaymentInProgress,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } catch (_) {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 4),
            const BillMetaChipStrip(),
            const SizedBox(height: 4),
            if (state.isEmpty)
              Expanded(
                child: AppEmptyState(
                  icon: Icons.point_of_sale_outlined,
                  title: context.l10n.tapProductToAdd,
                  message: context.l10n.cartTitle,
                ),
              )
            else
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 840),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        indent: 62,
                        endIndent: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                      itemBuilder: (_, index) {
                        final item = items[index];
                        final enableItemDiscount = context
                            .read<SettingsCubit>()
                            .state
                            .settings
                            .enableItemDiscount;
                        return RepaintBoundary(
                          key: ValueKey(item.lineId),
                          child: CartItemCard(
                            item: item,
                            currency: currency,
                            onImageTap: paymentLocked
                                ? () {}
                                : () => _showImageDialog(context, item),
                            onRowTap: paymentLocked
                                ? () {}
                                : () => CartProductDetailSheet.show(
                                    context,
                                    item,
                                    onEditNote: () =>
                                        _showItemNote(context, item),
                                    onEditDiscount: enableItemDiscount
                                        ? () => _showItemDiscount(context, item)
                                        : null,
                                  ),
                            onDecrement: paymentLocked
                                ? () {}
                                : () => _changeQty(context, item, -1),
                            onIncrement: paymentLocked
                                ? () {}
                                : () => _changeQty(context, item, 1),
                            onDelete: paymentLocked
                                ? () {}
                                : () => _removeItem(context, item),
                            onMoreActions: paymentLocked
                                ? null
                                : _CartItemActions(
                                    enableDiscount: enableItemDiscount,
                                    onDiscount: () =>
                                        _showItemDiscount(context, item),
                                    onNote: () => _showItemNote(context, item),
                                    onDuplicate: () =>
                                        _duplicateItem(context, item),
                                    onRemove: () => _removeItem(context, item),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            const CartReviewFooter(),
          ],
        );
      },
    );
  }

  static bool _isPaymentLocked(BuildContext context) {
    try {
      return context.read<CheckoutBloc>().state.status ==
          CheckoutStatus.waitingPayment;
    } catch (_) {
      return false;
    }
  }
}

class _CartItemActions extends StatelessWidget {
  const _CartItemActions({
    required this.enableDiscount,
    required this.onDiscount,
    required this.onNote,
    required this.onDuplicate,
    required this.onRemove,
  });

  final bool enableDiscount;
  final VoidCallback onDiscount;
  final VoidCallback onNote;
  final VoidCallback onDuplicate;
  final VoidCallback onRemove;

  Future<void> _openSheet(BuildContext context) async {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (enableDiscount)
                ListTile(
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(l10n.discountSectionLabel),
                  onTap: () {
                    Navigator.pop(ctx);
                    onDiscount();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.note_alt_outlined),
                title: Text(l10n.itemNoteLabel),
                onTap: () {
                  Navigator.pop(ctx);
                  onNote();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: Text(l10n.duplicateItemAction),
                onTap: () {
                  Navigator.pop(ctx);
                  onDuplicate();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  l10n.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onRemove();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
      icon: const Icon(Icons.more_horiz),
      onPressed: () => _openSheet(context),
    );
  }
}

/// Line / bill note dialog — owns controller for full IME + route lifecycle.
class _CartTextNoteDialog extends StatefulWidget {
  const _CartTextNoteDialog({
    required this.title,
    required this.initialValue,
    required this.labelText,
    required this.hintText,
    required this.cancelLabel,
    required this.saveLabel,
    required this.onSave,
  });

  final String title;
  final String initialValue;
  final String? labelText;
  final String? hintText;
  final String cancelLabel;
  final String saveLabel;
  final ValueChanged<String> onSave;

  @override
  State<_CartTextNoteDialog> createState() => _CartTextNoteDialogState();
}

class _CartTextNoteDialogState extends State<_CartTextNoteDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  void _pop() {
    unfocusForDialogClose();
    Navigator.pop(context);
  }

  void _submit() {
    widget.onSave(_ctrl.text.trim());
    _pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: _pop, child: Text(widget.cancelLabel)),
        FilledButton(onPressed: _submit, child: Text(widget.saveLabel)),
      ],
    );
  }
}
