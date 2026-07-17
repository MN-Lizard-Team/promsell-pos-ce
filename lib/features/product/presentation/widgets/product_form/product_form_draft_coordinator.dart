import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_image_handler.dart';

/// Create-only draft autosave / restore for [ProductFormPage].
///
/// Rules (must stay stable for tests + crash recovery):
/// - Never check/restore when editing an existing product.
/// - Never offer restore when [initialBarcode] is set (scan-create prefill).
/// - Autosave only on create, and not after submit.
class ProductFormDraftCoordinator {
  ProductFormDraftCoordinator({
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
    required bool Function() isEditing,
    required bool Function() isSubmitted,
    required bool Function() isMounted,
    required String? Function() initialBarcode,
    required Category? Function() selectedCategory,
    required bool Function() trackStock,
    required bool Function() isActive,
    required bool Function() isRecommended,
    required List<ProductOptionGroup> Function() optionGroups,
    required void Function(Category?) setSelectedCategory,
    required void Function(bool) setTrackStock,
    required void Function(bool) setIsActive,
    required void Function(bool) setIsRecommended,
    required void Function(List<ProductOptionGroup>) setOptionGroups,
    required VoidCallback onRestored,
  })  : _isEditing = isEditing,
        _isSubmitted = isSubmitted,
        _isMounted = isMounted,
        _initialBarcode = initialBarcode,
        _selectedCategory = selectedCategory,
        _trackStock = trackStock,
        _isActive = isActive,
        _isRecommended = isRecommended,
        _optionGroups = optionGroups,
        _setSelectedCategory = setSelectedCategory,
        _setTrackStock = setTrackStock,
        _setIsActive = setIsActive,
        _setIsRecommended = setIsRecommended,
        _setOptionGroups = setOptionGroups,
        _onRestored = onRestored;

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

  final bool Function() _isEditing;
  final bool Function() _isSubmitted;
  final bool Function() _isMounted;
  final String? Function() _initialBarcode;
  final Category? Function() _selectedCategory;
  final bool Function() _trackStock;
  final bool Function() _isActive;
  final bool Function() _isRecommended;
  final List<ProductOptionGroup> Function() _optionGroups;
  final void Function(Category?) _setSelectedCategory;
  final void Function(bool) _setTrackStock;
  final void Function(bool) _setIsActive;
  final void Function(bool) _setIsRecommended;
  final void Function(List<ProductOptionGroup>) _setOptionGroups;
  final VoidCallback _onRestored;

  Timer? _debounceTimer;

  void cancelDebounce() => _debounceTimer?.cancel();

  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Debounced autosave after field edits (create path only).
  void scheduleAutosave(BuildContext context) {
    if (_isEditing() || _isSubmitted()) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isMounted() || _isEditing() || _isSubmitted()) return;
      syncDraftToCubit(context);
      final cubit = context.read<ProductFormCubit>();
      if (cubit.draft.isEmpty) return;
      cubit.saveDraftToStorage();
    });
  }

  Future<void> checkDraft(BuildContext context) async {
    if (_isEditing()) return;
    // Scan-create: do not offer restore that can overwrite prefilled barcode.
    if (_initialBarcode()?.trim().isNotEmpty ?? false) return;
    final cubit = context.read<ProductFormCubit>();
    await cubit.draftLoaded;
    if (!context.mounted || !_isMounted()) return;
    final draft = cubit.draft;
    if (draft.isEmpty) return;

    await showRestoreDialog(context, draft);
  }

  Future<void> showRestoreDialog(
    BuildContext context,
    ProductDraft draft,
  ) async {
    final l10n = context.l10n;
    final footnoteParts = <String>[
      if (draft.price.isNotEmpty) '${l10n.sellingPrice}: ${draft.price}',
      if (draft.categoryName != null && draft.categoryName!.isNotEmpty)
        '${l10n.categoryLabel}: ${draft.categoryName}',
    ];
    final restore = await showAppConfirm(
      context,
      title: l10n.restoreDraft,
      message: l10n.unsavedChangesMessageCreate,
      detail: draft.name.isNotEmpty ? draft.name : null,
      footnote: footnoteParts.isEmpty ? null : footnoteParts.join(' · '),
      confirmLabel: l10n.restore,
      cancelLabel: l10n.discardDraft,
      destructive: false,
      icon: Icons.history_edu_outlined,
    );
    if (!context.mounted || !_isMounted()) return;
    if (restore) {
      _debounceTimer?.cancel();
      restoreDraft(context, draft);
    } else {
      context.read<ProductFormCubit>().clearDraft();
    }
  }

  void restoreDraft(BuildContext context, ProductDraft draft) {
    nameCtrl.text = draft.name;
    priceCtrl.text = draft.price;
    stockCtrl.text = draft.stock;
    skuCtrl.text = draft.sku;
    barcodeCtrl.text = draft.barcode;
    costCtrl.text = draft.cost;
    descriptionCtrl.text = draft.description;
    brandCtrl.text = draft.brand;
    unitCtrl.text = draft.unit;
    supplierCtrl.text = draft.supplier;
    _setTrackStock(draft.trackStock);
    _setIsActive(draft.isActive);
    _setIsRecommended(draft.isRecommended);
    _setOptionGroups(List.of(draft.optionGroups));

    if (draft.categoryId != null && draft.categoryName != null) {
      _setSelectedCategory(
        Category(
          id: draft.categoryId!,
          name: draft.categoryName!,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    }

    ProductDraft effectiveDraft = draft;
    if (draft.imagePath != null && File(draft.imagePath!).existsSync()) {
      imageHandler.imagePath = draft.imagePath;
      imageHandler.imageThumbnailPath = draft.imageThumbnailPath;
    } else if (draft.imagePath != null) {
      imageHandler.imagePath = null;
      imageHandler.imageThumbnailPath = null;
      effectiveDraft = draft.copyWith(
        imagePath: null,
        imageThumbnailPath: null,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted()) {
          AppSnackBar.info(context, context.l10n.imageNotFound);
        }
      });
    }

    context.read<ProductFormCubit>().restoreDraft(effectiveDraft);
    _onRestored();
  }

  void syncDraftToCubit(BuildContext context) {
    final cubit = context.read<ProductFormCubit>();
    cubit.syncDraftFromControllers(
      name: nameCtrl.text,
      price: priceCtrl.text,
      stock: stockCtrl.text,
      sku: skuCtrl.text,
      barcode: barcodeCtrl.text,
      cost: costCtrl.text,
      categoryId: _selectedCategory()?.id,
      categoryName: _selectedCategory()?.name,
      imagePath: imageHandler.imagePath,
      imageThumbnailPath: imageHandler.imageThumbnailPath,
      trackStock: _trackStock(),
      isActive: _isActive(),
      isRecommended: _isRecommended(),
      description: descriptionCtrl.text,
      brand: brandCtrl.text,
      unit: unitCtrl.text,
      supplier: supplierCtrl.text,
      optionGroups: _optionGroups(),
    );
  }
}
