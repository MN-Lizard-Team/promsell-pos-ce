import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/submit_product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/confirm_delete_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_view.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_image_handler.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/unsaved_changes_dialog.dart';

/// Submit / delete / unsaved-pop orchestration for [ProductFormPage].
///
/// Keeps [SubmitProductUseCase] rules and create-draft clear-on-discard intact.
class ProductFormLifecycle {
  ProductFormLifecycle({
    required this.formKey,
    required this.formViewKey,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.skuCtrl,
    required this.barcodeCtrl,
    required this.costCtrl,
    required this.descriptionCtrl,
    required this.brandCtrl,
    required this.unitCtrl,
    required this.supplierCtrl,
    required this.imageHandler,
    required Product? Function() product,
    required bool Function() isEditing,
    required bool Function() isMounted,
    required bool Function() isSubmitted,
    required void Function(bool) setSubmitted,
    required void Function(bool) setDeleting,
    required void Function(bool) setIsDirty,
    required VoidCallback onStateChanged,
    required Category? Function() selectedCategory,
    required bool Function() categoryWasChanged,
    required bool Function() isActive,
    required bool Function() isRecommended,
    required bool Function() trackStock,
    required List<ProductOptionGroup> Function() optionGroups,
  }) : _product = product,
       _isEditing = isEditing,
       _isMounted = isMounted,
       _isSubmitted = isSubmitted,
       _setSubmitted = setSubmitted,
       _setDeleting = setDeleting,
       _setIsDirty = setIsDirty,
       _onStateChanged = onStateChanged,
       _selectedCategory = selectedCategory,
       _categoryWasChanged = categoryWasChanged,
       _isActive = isActive,
       _isRecommended = isRecommended,
       _trackStock = trackStock,
       _optionGroups = optionGroups;

  final GlobalKey<FormState> formKey;
  final GlobalKey<ProductFormViewState> formViewKey;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController barcodeCtrl;
  final TextEditingController costCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController brandCtrl;
  final TextEditingController unitCtrl;
  final TextEditingController supplierCtrl;
  final ProductImageHandler imageHandler;

  final Product? Function() _product;
  final bool Function() _isEditing;
  final bool Function() _isMounted;
  final bool Function() _isSubmitted;
  final void Function(bool) _setSubmitted;
  final void Function(bool) _setDeleting;
  final void Function(bool) _setIsDirty;
  final VoidCallback _onStateChanged;
  final Category? Function() _selectedCategory;
  final bool Function() _categoryWasChanged;
  final bool Function() _isActive;
  final bool Function() _isRecommended;
  final bool Function() _trackStock;
  final List<ProductOptionGroup> Function() _optionGroups;

  int resolveStock(BuildContext context) {
    int? latestStock;
    final product = _product();
    if (_isEditing() && product != null) {
      final bloc = context.read<ProductBloc>();
      latestStock = bloc.state.products
          .where((p) => p.id == product.id)
          .firstOrNull
          ?.stock;
    }
    return ProductFormCubit.resolveStock(
      trackStock: _trackStock(),
      isEditing: _isEditing(),
      stockText: stockCtrl.text,
      latestStock: latestStock,
      baseStock: product?.stock,
    );
  }

  void submit(BuildContext context) {
    final bloc = context.read<ProductBloc>();
    if (_isSubmitted() || bloc.state.saveStatus == ProductSaveStatus.saving) {
      return;
    }
    if (!formKey.currentState!.validate()) {
      formViewKey.currentState?.revealFirstInvalidTab();
      // Re-validate after switching tab so error text is visible.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted()) formKey.currentState?.validate();
      });
      return;
    }
    _setSubmitted(true);
    _setIsDirty(false);
    _onStateChanged();
    final stock = resolveStock(context);
    final product = _product();
    final latest = _isEditing() && product != null
        ? bloc.state.products.where((p) => p.id == product.id).firstOrNull
        : null;

    final event = SubmitProductUseCase()(
      SubmitProductInput(
        isEditing: _isEditing(),
        name: nameCtrl.text,
        priceText: priceCtrl.text,
        stock: stock,
        sku: skuCtrl.text,
        barcode: barcodeCtrl.text,
        costText: costCtrl.text,
        selectedCategory: _selectedCategory(),
        categoryWasChanged: _categoryWasChanged(),
        imageUrl: imageHandler.imageUrl,
        imagePath: imageHandler.imagePath,
        imageThumbnailPath: imageHandler.imageThumbnailPath,
        isActive: _isActive(),
        trackStock: _trackStock(),
        description: descriptionCtrl.text,
        brand: brandCtrl.text,
        unit: unitCtrl.text,
        supplier: supplierCtrl.text,
        isRecommended: _isRecommended(),
        optionGroups: _optionGroups(),
        existingProduct: product,
        latestProduct: latest,
      ),
    );

    if (event == null) {
      _setSubmitted(false);
      _onStateChanged();
      return;
    }

    bloc.add(event);
  }

  Future<void> confirmDelete(BuildContext context) async {
    final product = _product();
    if (product == null) return;
    final confirmed = await showConfirmDeleteDialog(context, product.name);
    if (!context.mounted || !_isMounted() || !confirmed) return;
    _setDeleting(true);
    _setIsDirty(false);
    context.read<ProductBloc>().add(ProductDeleted(product.id));
  }

  Future<void> handlePop(
    BuildContext context,
    bool didPop,
    dynamic result,
  ) async {
    if (didPop) return;
    final action = await showUnsavedChangesDialog(
      context,
      isEditing: _isEditing(),
    );
    if (action == UnsavedDialogAction.save && context.mounted && _isMounted()) {
      submit(context);
    } else if (action == UnsavedDialogAction.discard &&
        context.mounted &&
        _isMounted()) {
      // Leave without saving the product. Clear create-draft so the next
      // open is clean (draft restore is only for crash/kill mid-create).
      if (!_isEditing()) {
        context.read<ProductFormCubit>().clearDraft();
      }
      imageHandler.deleteTempImages();
      Navigator.of(context).pop();
    }
  }
}
