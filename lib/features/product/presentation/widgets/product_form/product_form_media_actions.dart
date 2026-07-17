import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_image_handler.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Barcode generate + image pick wrappers for [ProductFormPage].
class ProductFormMediaActions {
  ProductFormMediaActions({
    required this.barcodeCtrl,
    required this.barcodeFocusNode,
    required this.imageHandler,
    required Product? Function() product,
    required bool Function() isMounted,
    required VoidCallback markDirty,
    required void Function(bool) setGeneratingBarcode,
    required void Function(bool) setPickingImage,
  })  : _product = product,
        _isMounted = isMounted,
        _markDirty = markDirty,
        _setGeneratingBarcode = setGeneratingBarcode,
        _setPickingImage = setPickingImage;

  final TextEditingController barcodeCtrl;
  final FocusNode barcodeFocusNode;
  final ProductImageHandler imageHandler;

  final Product? Function() _product;
  final bool Function() _isMounted;
  final VoidCallback _markDirty;
  final void Function(bool) _setGeneratingBarcode;
  final void Function(bool) _setPickingImage;

  Future<void> generateBarcode(BuildContext context) async {
    final l10n = context.l10n;
    final current = barcodeCtrl.text.trim();
    if (current.isNotEmpty) {
      final confirmed = await showConfirmationDialog(
        context,
        title: l10n.barcodeReplaceTitle,
        message: l10n.barcodeReplaceMessage(current),
        confirmLabel: l10n.confirm,
        cancelLabel: l10n.cancel,
      );
      if (!confirmed || !context.mounted || !_isMounted()) return;
    }

    final settings = context.read<SettingsCubit>().state.settings;
    final prefix = settings.barcodeAutoGeneratePrefix;
    _setGeneratingBarcode(true);
    try {
      final barcode = await context.read<ProductFormCubit>().generateBarcode(
        prefix: prefix,
        excludeId: _product()?.id,
      );
      if (!context.mounted || !_isMounted()) return;
      barcodeCtrl.text = barcode.toUpperCase();
      _markDirty();
      barcodeFocusNode.requestFocus();
      AppSnackBar.success(context, l10n.barcodeGenerated);
    } catch (_) {
      if (!context.mounted || !_isMounted()) return;
      AppSnackBar.error(context, l10n.errorOccurred);
    } finally {
      if (_isMounted()) _setGeneratingBarcode(false);
    }
  }

  Future<void> onImageTap(BuildContext context) async {
    _setPickingImage(true);
    try {
      final result = await imageHandler.handleImageTap(context);
      if (result != null && context.mounted && _isMounted()) {
        _markDirty();
      }
    } finally {
      if (_isMounted()) _setPickingImage(false);
    }
  }
}
