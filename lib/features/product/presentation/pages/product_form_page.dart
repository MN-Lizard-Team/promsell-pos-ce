import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/errors/app_error_display.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_draft_coordinator.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_lifecycle.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_media_actions.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_stock_actions.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_image_handler.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_option_group.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_hero_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_view.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_view_model.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/detail_header.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({
    super.key,
    this.product,
    this.imageService,
    this.initialBarcode,
  });
  final Product? product;
  final ProductImageService? imageService;

  /// Prefill barcode when creating from a failed sale scan (not-found CTA).
  final String? initialBarcode;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _formViewKey = GlobalKey<ProductFormViewState>();
  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  final _nameFocusNode = FocusNode();
  late final _priceCtrl = TextEditingController(
    text: widget.product?.price.value.toStringAsFixed(2) ?? '',
  );
  late final _stockCtrl = TextEditingController(
    text: widget.product?.stock.toString() ?? '0',
  );
  late final _skuCtrl = TextEditingController(text: widget.product?.sku ?? '');
  late final _barcodeCtrl = TextEditingController(
    text:
        widget.product?.barcode ??
        (widget.initialBarcode?.trim().toUpperCase() ?? ''),
  );
  late final _costCtrl = TextEditingController(
    text: () {
      final cost = widget.product?.cost;
      return cost != null ? cost.value.toStringAsFixed(2) : '';
    }(),
  );
  late final _descriptionCtrl = TextEditingController(
    text: widget.product?.description ?? '',
  );
  late final _brandCtrl = TextEditingController(
    text: widget.product?.brand ?? '',
  );
  late final _unitCtrl = TextEditingController(
    text: widget.product?.unit ?? '',
  );
  late final _supplierCtrl = TextEditingController(
    text: widget.product?.supplier ?? '',
  );

  late final ProductImageHandler _imageHandler;
  Category? _selectedCategory;
  bool _categoryWasChanged = false;
  late bool _isActive;
  late bool _isRecommended;
  late bool _trackStock;
  bool _isDirty = false;
  bool _deleting = false;
  bool _submitted = false;
  bool _isPickingImage = false;
  bool _isGeneratingBarcode = false;
  List<ProductOptionGroup> _optionGroups = [];
  final _barcodeFocusNode = FocusNode();
  late final ProductFormDraftCoordinator _draftCoordinator;
  late final ProductFormLifecycle _lifecycle;
  late final ProductFormStockActions _stockActions;
  late final ProductFormMediaActions _mediaActions;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _isActive = widget.product?.isActive ?? true;
    _isRecommended = widget.product?.isRecommended ?? false;
    _trackStock = widget.product?.trackStock ?? true;
    _imageHandler = ProductImageHandler(
      widget.imageService ?? sl<ProductImageService>(),
    );
    _imageHandler.imagePath = widget.product?.imagePath;
    _imageHandler.imageUrl = widget.product?.imageUrl;
    _imageHandler.imageThumbnailPath = widget.product?.imageThumbnailPath;
    _optionGroups = List.of(widget.product?.optionGroups ?? []);
    _draftCoordinator = ProductFormDraftCoordinator(
      nameCtrl: _nameCtrl,
      priceCtrl: _priceCtrl,
      stockCtrl: _stockCtrl,
      skuCtrl: _skuCtrl,
      barcodeCtrl: _barcodeCtrl,
      costCtrl: _costCtrl,
      descriptionCtrl: _descriptionCtrl,
      brandCtrl: _brandCtrl,
      unitCtrl: _unitCtrl,
      supplierCtrl: _supplierCtrl,
      imageHandler: _imageHandler,
      isEditing: () => _isEditing,
      isSubmitted: () => _submitted,
      isMounted: () => mounted,
      initialBarcode: () => widget.initialBarcode,
      selectedCategory: () => _selectedCategory,
      trackStock: () => _trackStock,
      isActive: () => _isActive,
      isRecommended: () => _isRecommended,
      optionGroups: () => _optionGroups,
      setSelectedCategory: (c) => _selectedCategory = c,
      setTrackStock: (v) => _trackStock = v,
      setIsActive: (v) => _isActive = v,
      setIsRecommended: (v) => _isRecommended = v,
      setOptionGroups: (g) => _optionGroups = g,
      onRestored: () {
        if (mounted) setState(() {});
      },
    );
    _lifecycle = ProductFormLifecycle(
      formKey: _formKey,
      formViewKey: _formViewKey,
      nameCtrl: _nameCtrl,
      priceCtrl: _priceCtrl,
      stockCtrl: _stockCtrl,
      skuCtrl: _skuCtrl,
      barcodeCtrl: _barcodeCtrl,
      costCtrl: _costCtrl,
      descriptionCtrl: _descriptionCtrl,
      brandCtrl: _brandCtrl,
      unitCtrl: _unitCtrl,
      supplierCtrl: _supplierCtrl,
      imageHandler: _imageHandler,
      product: () => widget.product,
      isEditing: () => _isEditing,
      isMounted: () => mounted,
      isSubmitted: () => _submitted,
      setSubmitted: (v) => _submitted = v,
      setDeleting: (v) => _deleting = v,
      setIsDirty: (v) => _isDirty = v,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      selectedCategory: () => _selectedCategory,
      categoryWasChanged: () => _categoryWasChanged,
      isActive: () => _isActive,
      isRecommended: () => _isRecommended,
      trackStock: () => _trackStock,
      optionGroups: () => _optionGroups,
    );
    _stockActions = ProductFormStockActions(
      stockCtrl: _stockCtrl,
      unitCtrl: _unitCtrl,
      product: () => widget.product,
      isEditing: () => _isEditing,
      isMounted: () => mounted,
      trackStock: () => _trackStock,
      setTrackStock: (v) => _trackStock = v,
      markDirty: _markDirty,
      onMarkDirtyListenerRemoved: () =>
          _stockCtrl.removeListener(_markDirty),
      onMarkDirtyListenerRestored: () => _stockCtrl.addListener(_markDirty),
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _mediaActions = ProductFormMediaActions(
      barcodeCtrl: _barcodeCtrl,
      barcodeFocusNode: _barcodeFocusNode,
      imageHandler: _imageHandler,
      product: () => widget.product,
      isMounted: () => mounted,
      markDirty: _markDirty,
      setGeneratingBarcode: (v) {
        if (mounted) setState(() => _isGeneratingBarcode = v);
      },
      setPickingImage: (v) {
        if (mounted) setState(() => _isPickingImage = v);
      },
    );
    _nameCtrl.addListener(_markDirty);
    _priceCtrl.addListener(_markDirty);
    _stockCtrl.addListener(_markDirty);
    _skuCtrl.addListener(_markDirty);
    _barcodeCtrl.addListener(_markDirty);
    _costCtrl.addListener(_markDirty);
    _descriptionCtrl.addListener(_markDirty);
    _brandCtrl.addListener(_markDirty);
    _unitCtrl.addListener(_markDirty);
    _supplierCtrl.addListener(_markDirty);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryLookupCategory();
      _draftCoordinator.checkDraft(context);
      // Scan-create: stay on Info and focus name (barcode already prefilled).
      if (!_isEditing && (widget.initialBarcode?.trim().isNotEmpty ?? false)) {
        _formViewKey.currentState?.goToTab(0);
        _nameFocusNode.requestFocus();
      }
    });
  }

  void _markDirty() {
    _isDirty = true;
    setState(() {});
    _draftCoordinator.scheduleAutosave(context);
  }

  void _tryLookupCategory() {
    final categories = context.read<CategoryBloc>().state.categories;
    // Do not re-apply product.categoryId after the user cleared/changed it.
    if (categories.isEmpty ||
        _selectedCategory != null ||
        _categoryWasChanged) {
      return;
    }
    final catId = widget.product?.categoryId;
    if (catId == null || catId.isEmpty) return;
    final found = categories.where((c) => c.id == catId).firstOrNull;
    if (found != null) {
      setState(() => _selectedCategory = found);
    }
  }

  @override
  void dispose() {
    // Drop IME / focus before tearing down controllers so rebuilds during
    // route exit do not re-attach listeners to disposed TextEditingControllers.
    FocusManager.instance.primaryFocus?.unfocus();
    _draftCoordinator.dispose();
    _nameCtrl.removeListener(_markDirty);
    _priceCtrl.removeListener(_markDirty);
    _stockCtrl.removeListener(_markDirty);
    _skuCtrl.removeListener(_markDirty);
    _barcodeCtrl.removeListener(_markDirty);
    _costCtrl.removeListener(_markDirty);
    _descriptionCtrl.removeListener(_markDirty);
    _brandCtrl.removeListener(_markDirty);
    _unitCtrl.removeListener(_markDirty);
    _supplierCtrl.removeListener(_markDirty);
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _barcodeFocusNode.dispose();
    _nameFocusNode.dispose();
    _costCtrl.dispose();
    _descriptionCtrl.dispose();
    _brandCtrl.dispose();
    _unitCtrl.dispose();
    _supplierCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listenWhen: (prev, curr) =>
              prev.categories != curr.categories &&
              curr.categories.isNotEmpty &&
              _selectedCategory == null,
          listener: (ctx, state) => _tryLookupCategory(),
        ),
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) =>
              (_submitted || _deleting) && prev.saveStatus != curr.saveStatus,
          listener: (ctx, state) async {
            if (state.saveStatus == ProductSaveStatus.saved) {
              final wasDeleting = _deleting;
              if (!_isEditing) {
                ctx.read<ProductFormCubit>().clearDraft();
              }
              if (ctx.mounted) {
                AppSnackBar.success(
                  ctx,
                  wasDeleting ? ctx.l10n.productDeleted : ctx.l10n.productSaved,
                );
                // Create: return the saved Product so callers can open preview.
                // Edit/delete: keep bool for existing callers (showProductEditPage).
                if (wasDeleting || _isEditing) {
                  Navigator.pop(ctx, true);
                } else {
                  final created = state.products.isNotEmpty
                      ? state.products.first
                      : null;
                  Navigator.pop(ctx, created ?? true);
                }
              }
            } else if (state.saveStatus == ProductSaveStatus.error) {
              _submitted = false;
              _deleting = false;
              setState(() {});
              AppSnackBar.error(
                ctx,
                state.error?.displayMessage(ctx.l10n) ?? ctx.l10n.errorOccurred,
              );
            }
          },
        ),
      ],
      child: PopScope(
        // Never allow system back while save/delete is in flight (avoids
        // popping with null before the success listener runs).
        canPop: !_isDirty && !_submitted && !_deleting,
        onPopInvokedWithResult: (didPop, result) =>
            _lifecycle.handlePop(context, didPop, result),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          bottomNavigationBar:
              BlocSelector<ProductBloc, ProductState, ProductSaveStatus>(
                selector: (state) => state.saveStatus,
                builder: (_, saveStatus) {
                  final isSaving = saveStatus == ProductSaveStatus.saving;
                  final l10n = context.l10n;
                  return StickyActionBar(
                    sideBySide: true,
                    primaryKey: const ValueKey('product-form-save'),
                    primaryLabel: _isEditing
                        ? l10n.saveProduct
                        : l10n.addProduct,
                    primaryColor: AppColors.accent,
                    onPrimary: () => _lifecycle.submit(context),
                    secondaryLabel: l10n.cancel,
                    onSecondary: () => Navigator.maybePop(context),
                    isLoading: isSaving,
                  );
                },
              ),
          body: _buildBody(context),
        ),
      ),
    );
  }

  void _showFormMenu() {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const ValueKey('product-form-more-menu'),
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                l10n.deleteProduct,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _lifecycle.confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final headerHeight =
        viewPadding.top + kToolbarHeight + DetailHeader.cardOverlapOffset;

    return SafeArea(
      top: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: DetailHeader(
              title: _isEditing
                  ? context.l10n.editProductTitle
                  : context.l10n.addProduct,
              isActive: _isActive,
              onBack: () => Navigator.maybePop(context),
              // isActive is edited only on Product tab (single source).
              onMenu: _isEditing ? _showFormMenu : null,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: headerHeight),
              // Hero: image + name + sellability + live price/stock metrics.
              ProductFormHeroCard(
                imagePath: _imageHandler.imagePath,
                imageUrl: _imageHandler.imageUrl,
                categoryName: _selectedCategory?.name,
                isLoading: _isPickingImage,
                onImageTap: () => _mediaActions.onImageTap(context),
                nameCtrl: _nameCtrl,
                priceCtrl: _priceCtrl,
                stockCtrl: _stockCtrl,
                costCtrl: _costCtrl,
                barcodeCtrl: _barcodeCtrl,
                unitCtrl: _unitCtrl,
                isActive: _isActive,
                isRecommended: _isRecommended,
                trackStock: _trackStock,
                currency: context
                    .watch<SettingsCubit>()
                    .state
                    .settings
                    .currency,
                onGoToTab: (i) => _formViewKey.currentState?.goToTab(i),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ProductFormView(
                  key: _formViewKey,
                  model: ProductFormViewModel(
                    formKey: _formKey,
                    product: widget.product,
                    controllers: ProductFormControllers(
                      nameCtrl: _nameCtrl,
                      priceCtrl: _priceCtrl,
                      stockCtrl: _stockCtrl,
                      skuCtrl: _skuCtrl,
                      barcodeCtrl: _barcodeCtrl,
                      barcodeFocusNode: _barcodeFocusNode,
                      nameFocusNode: _nameFocusNode,
                      costCtrl: _costCtrl,
                      descriptionCtrl: _descriptionCtrl,
                      brandCtrl: _brandCtrl,
                      unitCtrl: _unitCtrl,
                      supplierCtrl: _supplierCtrl,
                    ),
                    state: ProductFormStateData(
                      selectedCategory: _selectedCategory,
                      imageUrl: _imageHandler.imageUrl,
                      imagePath: _imageHandler.imagePath,
                      isActive: _isActive,
                      isRecommended: _isRecommended,
                      trackStock: _trackStock,
                      isPickingImage: _isPickingImage,
                      isGeneratingBarcode: _isGeneratingBarcode,
                    ),
                    callbacks: ProductFormCallbacks(
                      onCategoryChanged: (cat) {
                        _markDirty();
                        setState(() {
                          _selectedCategory = cat;
                          _categoryWasChanged = true;
                        });
                      },
                      onImageTap: () => _mediaActions.onImageTap(context),
                      onActiveChanged: (v) {
                        _markDirty();
                        setState(() => _isActive = v);
                      },
                      onRecommendedChanged: (v) {
                        _markDirty();
                        setState(() => _isRecommended = v);
                      },
                      onTrackStockChanged: (v) =>
                          _stockActions.handleTrackStockToggle(context, v),
                      onStockChanged: (v) {
                        _markDirty();
                        setState(() => _stockCtrl.text = v.toString());
                      },
                      onAdjustStock: () => _stockActions.adjustStock(context),
                      onGenerateBarcode: () =>
                          _mediaActions.generateBarcode(context),
                    ),
                    optionGroups: _optionGroups,
                    onOptionGroupsChanged: (groups) {
                      _markDirty();
                      setState(() => _optionGroups = groups);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
