import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_edit_tab_view/product_info_tab.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_edit_tab_view/product_pricing_tab.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_edit_tab_view/product_settings_tab.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_edit_tab_view/product_stock_tab.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductEditTabView extends StatelessWidget {
  const ProductEditTabView({
    super.key,
    required this.product,
    required this.formKey,
    required this.nameCtrl,
    required this.priceCtrl,
    required this.stockCtrl,
    required this.skuCtrl,
    required this.barcodeCtrl,
    required this.costCtrl,
    required this.selectedCategory,
    required this.imagePath,
    required this.imageUrl,
    required this.isActive,
    required this.trackStock,
    required this.isPickingImage,
    required this.onCategoryChanged,
    required this.onImageTap,
    required this.onActiveChanged,
    required this.onTrackStockChanged,
    required this.onStockChanged,
    required this.onDelete,
  });

  final Product? product;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController stockCtrl;
  final TextEditingController skuCtrl;
  final TextEditingController barcodeCtrl;
  final TextEditingController costCtrl;
  final Category? selectedCategory;
  final String? imagePath;
  final String? imageUrl;
  final bool isActive;
  final bool trackStock;
  final bool isPickingImage;
  final ValueChanged<Category?> onCategoryChanged;
  final VoidCallback onImageTap;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onTrackStockChanged;
  final ValueChanged<int> onStockChanged;
  final VoidCallback onDelete;

  bool get isEditing => product != null;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Form(
      key: formKey,
      child: TabBarView(
        children: [
          ProductInfoTab(
            nameCtrl: nameCtrl,
            skuCtrl: skuCtrl,
            barcodeCtrl: barcodeCtrl,
            selectedCategory: selectedCategory,
            imagePath: imagePath,
            imageUrl: imageUrl,
            categoryName: selectedCategory?.name,
            isPickingImage: isPickingImage,
            onImageTap: onImageTap,
            onCategoryChanged: onCategoryChanged,
          ),
          ProductPricingTab(
            priceCtrl: priceCtrl,
            costCtrl: costCtrl,
            currency: currency,
          ),
          ProductStockTab(
            stockCtrl: stockCtrl,
            trackStock: trackStock,
            onStockChanged: onStockChanged,
            onTrackStockChanged: onTrackStockChanged,
          ),
          ProductSettingsTab(
            isActive: isActive,
            isEditing: isEditing,
            onActiveChanged: onActiveChanged,
            onDelete: onDelete,
            productName: product?.name ?? '',
          ),
        ],
      ),
    );
  }
}
