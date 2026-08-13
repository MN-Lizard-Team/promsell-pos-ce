import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';

class ProductFormViewModel {
  const ProductFormViewModel({
    required this.formKey,
    required this.product,
    required this.controllers,
    required this.state,
    required this.callbacks,
    required this.optionGroups,
    required this.onOptionGroupsChanged,
  });

  final GlobalKey<FormState> formKey;
  final Product? product;
  final ProductFormControllers controllers;
  final ProductFormStateData state;
  final ProductFormCallbacks callbacks;
  final List<ProductOptionGroup> optionGroups;
  final ValueChanged<List<ProductOptionGroup>> onOptionGroupsChanged;

  bool get isEditing => product != null;
}

class ProductFormControllers {
  const ProductFormControllers({
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.skuCtrl,
    required this.skuFocusNode,
    required this.barcodeCtrl,
    required this.barcodeFocusNode,
    this.nameFocusNode,
    required this.costCtrl,
    required this.descriptionCtrl,
    required this.brandCtrl,
    required this.unitCtrl,
    required this.supplierCtrl,
  });

  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController skuCtrl;
  final FocusNode skuFocusNode;
  final TextEditingController barcodeCtrl;
  final FocusNode barcodeFocusNode;
  final FocusNode? nameFocusNode;
  final TextEditingController costCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController brandCtrl;
  final TextEditingController unitCtrl;
  final TextEditingController supplierCtrl;
}

class ProductFormStateData {
  const ProductFormStateData({
    required this.selectedCategory,
    required this.imageUrl,
    required this.imagePath,
    required this.isActive,
    required this.isRecommended,
    required this.trackStock,
    required this.isPickingImage,
    required this.isGeneratingBarcode,
    required this.isGeneratingSku,
  });

  final Category? selectedCategory;
  final String? imageUrl;
  final String? imagePath;
  final bool isActive;
  final bool isRecommended;
  final bool trackStock;
  final bool isPickingImage;
  final bool isGeneratingBarcode;
  final bool isGeneratingSku;
}

class ProductFormCallbacks {
  const ProductFormCallbacks({
    required this.onCategoryChanged,
    required this.onImageTap,
    required this.onTrackStockChanged,
    required this.onActiveChanged,
    required this.onRecommendedChanged,
    required this.onStockChanged,
    required this.onAdjustStock,
    required this.onGenerateBarcode,
    required this.onGenerateSku,
  });

  final ValueChanged<Category?> onCategoryChanged;
  final VoidCallback onImageTap;
  final ValueChanged<bool> onTrackStockChanged;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onRecommendedChanged;
  final ValueChanged<int> onStockChanged;
  final VoidCallback onAdjustStock;
  final VoidCallback onGenerateBarcode;
  final VoidCallback onGenerateSku;
}
