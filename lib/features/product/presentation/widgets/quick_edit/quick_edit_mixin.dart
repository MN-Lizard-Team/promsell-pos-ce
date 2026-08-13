import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit/quick_edit_sheet.dart';

/// Quick-edit actions for name / price / stock from product preview.
///
/// These intentionally dispatch [ProductUpdated] WITHOUT `optionGroups` so
/// the data layer's `updateProduct` (not `updateProductWithOptionGroups`) is
/// used. Option groups are therefore preserved as-is in the database and
/// not re-fetched/replaced on a quick edit. If a future quick-edit surface
/// exposes option groups, pass `optionGroups: product.optionGroups` to keep
/// them in sync instead of silently dropping them.
mixin QuickEditMixin<T extends StatefulWidget> on State<T> {
  Product get product;
  void onProductUpdated(Product updated) {}

  Future<void> quickEditName(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.name,
      initialValue: product.name,
      productName: product.name,
    );
    if (!context.mounted) return;
    final trimmed = result?.trim();
    if (trimmed == null || trimmed.isEmpty) return;
    if (trimmed == product.name) {
      AppSnackBar.warning(context, l10n.quickEditNameCancelled);
      return;
    }
    if (trimmed.length > 100) {
      AppSnackBar.error(context, l10n.quickEditNameInvalid);
      return;
    }
    final updated = product.copyWith(name: trimmed);
    context.read<ProductBloc>().add(ProductUpdated(updated));
    onProductUpdated(updated);
    AppSnackBar.success(context, l10n.quickEditNameSaved);
  }

  Future<void> quickEditPrice(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.price,
      initialValue: product.price.value.toStringAsFixed(2),
      productName: product.name,
    );
    if (!context.mounted) return;
    final price = double.tryParse(result?.trim() ?? '');
    if (price == null || price < 0) {
      if (result != null && result.trim().isNotEmpty) {
        AppSnackBar.error(context, l10n.quickEditPriceInvalid);
      }
      return;
    }
    if (price == product.price.value) {
      AppSnackBar.warning(context, l10n.quickEditPriceCancelled);
      return;
    }
    final updated = product.copyWith(price: Money.fromDouble(price));
    context.read<ProductBloc>().add(ProductUpdated(updated));
    onProductUpdated(updated);
    AppSnackBar.success(context, l10n.quickEditPriceSaved);
  }

  Future<void> quickEditStock(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.stock,
      initialValue: product.stock.toString(),
      productName: product.name,
    );
    if (!context.mounted) return;
    final stock = int.tryParse(result ?? '');
    if (stock == null || stock < 0) {
      if (result != null && result.isNotEmpty) {
        AppSnackBar.error(context, l10n.stockUpdateInvalid);
      }
      return;
    }
    if (stock == product.stock) {
      AppSnackBar.warning(context, l10n.stockUpdateCancelled);
      return;
    }
    final updated = product.copyWith(stock: stock);
    context.read<ProductBloc>().add(ProductUpdated(updated));
    onProductUpdated(updated);
    AppSnackBar.success(context, l10n.stockUpdated);
  }
}
