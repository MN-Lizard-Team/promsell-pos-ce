import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/product_option_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Outcome of [saleAddToCart] for callers that need UI feedback.
enum SaleAddResult {
  /// Line added or qty increased without opening options UI.
  added,

  /// Option sheet shown; cart updates after user confirms.
  optionsOpened,

  /// Blocked: tracked stock is zero and oversell is off.
  blockedOos,

  /// Blocked for another reason (e.g. invalid qty).
  blocked,
}

/// Shared POS add-to-cart path for Sale catalog cards and Sale search.
///
/// Opens [ProductOptionSheet] when the product has option groups.
/// Does not navigate away — callers stay on the current surface.
Future<SaleAddResult> saleAddToCart(
  BuildContext context,
  Product product, {
  int qty = 1,
}) async {
  if (qty <= 0) return SaleAddResult.blocked;

  final allowOversell = context
      .read<SettingsCubit>()
      .state
      .settings
      .allowOversell;
  final outOfStock = product.trackStock && product.stock == 0;
  if (outOfStock && !allowOversell) {
    HapticFeedback.heavyImpact();
    return SaleAddResult.blockedOos;
  }

  HapticFeedback.selectionClick();

  final cartBloc = context.read<CartBloc>();

  if (product.optionGroups.isNotEmpty) {
    if (!context.mounted) return SaleAddResult.blocked;
    ProductOptionSheet.show(
      context,
      product: product,
      onConfirm: (options) {
        cartBloc.add(
          CartProductAdded(
            product,
            qty: qty,
            allowOversell: allowOversell,
            selectedOptions: options,
          ),
        );
      },
    );
    return SaleAddResult.optionsOpened;
  }

  cartBloc.add(
    CartProductAdded(product, qty: qty, allowOversell: allowOversell),
  );
  return SaleAddResult.added;
}

/// Long-press qty entry used by [SaleProductCard].
Future<SaleAddResult> saleAddToCartWithQtyDialog(
  BuildContext context,
  Product product, {
  required int currentCartQty,
}) async {
  final settings = context.read<SettingsCubit>().state.settings;
  final allowOversell = settings.allowOversell;
  final outOfStock = product.trackStock && product.stock == 0;
  if (outOfStock && !allowOversell) {
    HapticFeedback.heavyImpact();
    return SaleAddResult.blockedOos;
  }

  final controller = TextEditingController(text: '1');
  final qty = await showDialog<int>(
    context: context,
    builder: (dialogCtx) {
      final l10n = dialogCtx.l10n;
      return AlertDialog(
        title: Text(product.name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: InputDecoration(
            labelText: l10n.quantityLabel,
            suffixText: product.trackStock
                ? l10n.stockLabel(product.stock)
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              if (parsed == null || parsed <= 0) {
                Navigator.pop(dialogCtx);
                return;
              }
              var clamped = parsed;
              if (product.trackStock && !allowOversell) {
                clamped = parsed.clamp(1, product.stock);
              }
              Navigator.pop(dialogCtx, clamped);
            },
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (qty == null || !context.mounted) return SaleAddResult.blocked;
  return saleAddToCart(context, product, qty: qty);
}
