import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/features/inventory/presentation/widgets/dialogs/adjust_stock_dialog.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';

/// Stock adjust dialog + trackStock toggle for [ProductFormPage].
class ProductFormStockActions {
  ProductFormStockActions({
    required this.stockCtrl,
    required this.unitCtrl,
    required Product? Function() product,
    required bool Function() isEditing,
    required bool Function() isMounted,
    required bool Function() trackStock,
    required void Function(bool) setTrackStock,
    required VoidCallback markDirty,
    required VoidCallback onMarkDirtyListenerRemoved,
    required VoidCallback onMarkDirtyListenerRestored,
    required VoidCallback onStateChanged,
  })  : _product = product,
        _isEditing = isEditing,
        _isMounted = isMounted,
        _trackStock = trackStock,
        _setTrackStock = setTrackStock,
        _markDirty = markDirty,
        _onMarkDirtyListenerRemoved = onMarkDirtyListenerRemoved,
        _onMarkDirtyListenerRestored = onMarkDirtyListenerRestored,
        _onStateChanged = onStateChanged;

  final TextEditingController stockCtrl;
  final TextEditingController unitCtrl;

  final Product? Function() _product;
  final bool Function() _isEditing;
  final bool Function() _isMounted;
  final bool Function() _trackStock;
  final void Function(bool) _setTrackStock;
  final VoidCallback _markDirty;
  final VoidCallback _onMarkDirtyListenerRemoved;
  final VoidCallback _onMarkDirtyListenerRestored;
  final VoidCallback _onStateChanged;

  Future<void> adjustStock(BuildContext context) async {
    if (!_isEditing()) return;
    final product = _product();
    if (product == null) return;
    final latest = context
        .read<ProductBloc>()
        .state
        .products
        .where((p) => p.id == product.id)
        .firstOrNull;
    if (latest == null) return;
    final currentStock = int.tryParse(stockCtrl.text) ?? latest.stock;
    final unit =
        unitCtrl.text.trim().isEmpty ? latest.unit : unitCtrl.text.trim();
    final newStock = await showAdjustStockDialog(
      context,
      productId: latest.id,
      productName: latest.name,
      currentStock: currentStock,
      unit: unit,
    );
    if (!context.mounted || !_isMounted() || newStock == null) return;
    // Stock was committed via inventory log — sync field without marking draft dirty.
    _onMarkDirtyListenerRemoved();
    stockCtrl.text = newStock.toString();
    _onMarkDirtyListenerRestored();
    _onStateChanged();
  }

  Future<void> handleTrackStockToggle(BuildContext context, bool v) async {
    final bloc = context.read<ProductBloc>();
    if (!v && _trackStock()) {
      final l10n = context.l10n;
      final confirmed = await showConfirmationDialog(
        context,
        title: l10n.trackStock,
        message: l10n.trackStockDisableConfirm,
        confirmLabel: l10n.confirm,
        cancelLabel: l10n.cancel,
      );
      if (!confirmed || !context.mounted || !_isMounted()) return;
    }
    _markDirty();
    final product = _product();
    if (v &&
        _isEditing() &&
        product != null &&
        int.tryParse(stockCtrl.text) == 0 &&
        _isMounted()) {
      final latest = bloc.state.products
          .where((p) => p.id == product.id)
          .firstOrNull;
      final restoreStock = latest?.stock ?? product.stock;
      if (restoreStock > 0) {
        stockCtrl.text = restoreStock.toString();
      }
    }
    _setTrackStock(v);
    _onStateChanged();
  }
}
