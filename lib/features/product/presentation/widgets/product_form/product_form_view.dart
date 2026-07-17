import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/modern_toggle_card.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/category_field.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/option_groups_editor.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_shared.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_price_section.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_stock_section.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_visibility_strip.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_view_model.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/product_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Product form body: pill TabBar + pages under pinned hero.
/// Tab order: Product → Price → Stock → Codes (POS workflow).
class ProductFormView extends StatefulWidget {
  const ProductFormView({super.key, required this.model});

  final ProductFormViewModel model;

  @override
  State<ProductFormView> createState() => ProductFormViewState();
}

class ProductFormViewState extends State<ProductFormView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  /// 0=Product, 1=Price, 2=Stock, 3=Codes
  void goToTab(int index) {
    if (index < 0 || index >= _tabController.length) return;
    _tabController.animateTo(index);
    setState(() {});
  }

  /// After [FormState.validate] fails, show the first tab with invalid fields.
  void revealFirstInvalidTab() {
    final c = widget.model.controllers;
    if (c.nameCtrl.text.trim().isEmpty) {
      goToTab(0);
      return;
    }
    final price = double.tryParse(c.priceCtrl.text);
    if (c.priceCtrl.text.isEmpty || price == null || price <= 0) {
      goToTab(1);
      return;
    }
    final costText = c.costCtrl.text.trim();
    if (costText.isNotEmpty) {
      final cost = double.tryParse(costText);
      if (cost == null || cost < 0) {
        goToTab(1);
        return;
      }
    }
    final barcode = c.barcodeCtrl.text.trim();
    if (barcode.isNotEmpty && !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(barcode)) {
      goToTab(3);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = context.watch<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final lowStockThreshold = settings.lowStockThreshold;
    final c = widget.model.controllers;
    final s = widget.model.state;
    final cb = widget.model.callbacks;
    final isEditing = widget.model.isEditing;
    final currencySuffix = currency.trim().isEmpty
        ? l10n.currencyBaht
        : currency;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // 0 Product | 1 Price | 2 Stock | 3 Codes
    final pages = <Widget>[
      // —— Product ——
      _scroll(
        children: [
          FormSectionCard(
            title: l10n.productFormSectionGeneral,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProductTextField(
                  key: const ValueKey('product-form-name'),
                  controller: c.nameCtrl,
                  focusNode: c.nameFocusNode,
                  labelText: l10n.productNameLabel,
                  icon: Icons.badge_outlined,
                  maxLength: 200,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? l10n.productNameRequired
                      : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                CategoryField(
                  key: const ValueKey('product-form-category'),
                  selectedCategory: s.selectedCategory,
                  onChanged: cb.onCategoryChanged,
                ),
                const SizedBox(height: 12),
                ProductTextField(
                  controller: c.brandCtrl,
                  labelText: l10n.productBrandLabel,
                  icon: Icons.business_outlined,
                  helperText: l10n.productBrandHint,
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                ProductTextField(
                  controller: c.descriptionCtrl,
                  labelText: l10n.productDescriptionLabel,
                  icon: Icons.description_outlined,
                  helperText: l10n.productDescriptionHint,
                  maxLines: 3,
                  maxLength: 500,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            title: l10n.productFormSectionVisibility,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ModernToggleCard(
                  icon: Icons.visibility_outlined,
                  title: l10n.showProduct,
                  subtitle: l10n.showProductHint,
                  value: s.isActive,
                  onChanged: (v) {
                    if (!v && s.isRecommended) {
                      AppSnackBar.warning(
                        context,
                        l10n.productRecommendedNeedsVisible,
                      );
                    }
                    cb.onActiveChanged(v);
                  },
                ),
                const SizedBox(height: 12),
                ModernToggleCard(
                  icon: Icons.star_outline,
                  title: l10n.productRecommended,
                  subtitle: l10n.productRecommendedHint,
                  value: s.isRecommended,
                  onChanged: (v) {
                    if (v && !s.isActive) {
                      AppSnackBar.warning(
                        context,
                        l10n.productRecommendedNeedsVisible,
                      );
                      return; // hard block until product is visible
                    }
                    cb.onRecommendedChanged(v);
                  },
                ),
                const SizedBox(height: 12),
                ProductFormVisibilityOutcomeStrip(
                  isActive: s.isActive,
                  isRecommended: s.isRecommended,
                ),
              ],
            ),
          ),
        ],
      ),
      // —— Price ——
      _scroll(
        children: [
          FormSectionCard(
            title: l10n.productFormSectionPricing,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProductFormPriceDeltaStrip(
                  priceCtrl: c.priceCtrl,
                  costCtrl: c.costCtrl,
                  baselinePrice: widget.model.product?.price,
                  baselineCost: widget.model.product?.cost,
                  currency: currencySuffix,
                ),
                ProductTextField(
                  key: const ValueKey('product-form-price'),
                  controller: c.priceCtrl,
                  labelText: l10n.sellingPrice,
                  icon: Icons.sell_outlined,
                  showIcon: false,
                  suffixText: currencySuffix,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.priceRequired;
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null) {
                      return l10n.invalidPrice;
                    }
                    if (parsed <= 0) {
                      return l10n.priceMustBePositive;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                ProductTextField(
                  key: const ValueKey('product-form-cost'),
                  controller: c.costCtrl,
                  labelText: l10n.productPreviewCost,
                  helperText: l10n.costHelper,
                  icon: Icons.price_change_outlined,
                  showIcon: false,
                  suffixText: currencySuffix,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null;
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed < 0) {
                      return l10n.invalidPrice;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ProductFormMarkupPresetChips(
                  priceCtrl: c.priceCtrl,
                  costCtrl: c.costCtrl,
                ),
                const SizedBox(height: 12),
                ProductFormPriceInsights(
                  priceCtrl: c.priceCtrl,
                  costCtrl: c.costCtrl,
                  stockCtrl: c.stockCtrl,
                  trackStock: s.trackStock,
                  currency: currencySuffix,
                ),
              ],
            ),
          ),
        ],
      ),
      // —— Stock ——
      _scroll(
        children: [
          FormSectionCard(
            title: l10n.productFormSectionStock,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UnitField(controller: c.unitCtrl),
                const SizedBox(height: 12),
                ProductFormStockQuantitySection(
                  stockCtrl: c.stockCtrl,
                  unitCtrl: c.unitCtrl,
                  trackStock: s.trackStock,
                  isEditing: isEditing,
                  lowStockThreshold: lowStockThreshold,
                  onStockChanged: cb.onStockChanged,
                  onAdjustStock: cb.onAdjustStock,
                ),
                const SizedBox(height: 12),
                ModernToggleCard(
                  icon: Icons.inventory_2,
                  title: l10n.trackStock,
                  subtitle: l10n.trackStockHint,
                  value: s.trackStock,
                  onChanged: cb.onTrackStockChanged,
                ),
              ],
            ),
          ),
          if (s.trackStock) ...[
            const SizedBox(height: 16),
            ProductFormStockValueCard(
              priceCtrl: c.priceCtrl,
              costCtrl: c.costCtrl,
              stockCtrl: c.stockCtrl,
              currency: currencySuffix,
            ),
          ],
        ],
      ),
      // —— Codes ——
      _scroll(
        children: [
          FormSectionCard(
            title: l10n.barcodeLabel,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BarcodeField(
                  barcodeCtrl: c.barcodeCtrl,
                  barcodeFocusNode: c.barcodeFocusNode,
                  isGeneratingBarcode: s.isGeneratingBarcode,
                  onGenerateBarcode: cb.onGenerateBarcode,
                ),
                const SizedBox(height: 12),
                ProductTextField(
                  key: const ValueKey('product-form-sku'),
                  controller: c.skuCtrl,
                  labelText: l10n.skuLabel,
                  helperText: l10n.skuHelper,
                  icon: Icons.qr_code,
                  showIcon: false,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FormSectionCard(
            key: const ValueKey('product-form-supplier-section'),
            icon: Icons.local_shipping_outlined,
            title: l10n.productSupplierLabel,
            child: ProductTextField(
              controller: c.supplierCtrl,
              labelText: l10n.productSupplierLabel,
              helperText: l10n.productSupplierHint,
              icon: Icons.local_shipping_outlined,
              showIcon: false,
              maxLength: 100,
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 16),
          OptionGroupsEditor(
            key: const ValueKey('product-form-options-section'),
            initialGroups: widget.model.optionGroups,
            onChanged: widget.model.onOptionGroupsChanged,
          ),
        ],
      ),
    ];

    return Form(
      key: widget.model.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: _tabController,
                  tabAlignment: TabAlignment.fill,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: cs.onPrimaryContainer,
                  unselectedLabelColor: cs.onSurfaceVariant,
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: theme.textTheme.labelLarge,
                  tabs: [
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.article_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text(l10n.tabInfo),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.price_check_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text(l10n.tabPrice),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inventory_2_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text(l10n.tabStock),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.qr_code_2_outlined, size: 16),
                            const SizedBox(width: 4),
                            Text(l10n.tabCodes),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(index: _tabController.index, children: pages),
          ),
        ],
      ),
    );
  }

  Widget _scroll({required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Qty + unit + status chip + edit adjust hint (Stock tab body).
