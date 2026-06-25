import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_add/image_source_handler.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_edit_tab_view.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/confirm_delete_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/unsaved_changes_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});
  final Product? product;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.product?.name);
  late final _priceCtrl = TextEditingController(
    text: widget.product?.price.toStringAsFixed(2) ?? '',
  );
  late final _stockCtrl = TextEditingController(
    text: widget.product?.stock.toString() ?? '0',
  );
  late final _skuCtrl = TextEditingController(text: widget.product?.sku ?? '');
  late final _barcodeCtrl = TextEditingController(
    text: widget.product?.barcode ?? '',
  );
  late final _costCtrl = TextEditingController(
    text: () {
      final cost = widget.product?.cost;
      return cost != null ? cost.toStringAsFixed(2) : '';
    }(),
  );
  Category? _selectedCategory;
  String? _imagePath;
  String? _imageUrl;
  String? _imageThumbnailPath;
  late bool _isActive;
  late bool _trackStock;
  bool _isDirty = false;
  bool _deleting = false;
  bool _submitted = false;
  bool _isGeneratingBarcode = false;
  final List<String> _tempImagePaths = [];

  late final ImageSourceHandler _imageHandler;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _isActive = widget.product?.isActive ?? true;
    _trackStock = widget.product?.trackStock ?? true;
    _imagePath = widget.product?.imagePath;
    _imageUrl = widget.product?.imageUrl;
    _imageThumbnailPath = widget.product?.imageThumbnailPath;
    _nameCtrl.addListener(_markDirty);
    _priceCtrl.addListener(_markDirty);
    _stockCtrl.addListener(_markDirty);
    _skuCtrl.addListener(_markDirty);
    _barcodeCtrl.addListener(_markDirty);
    _costCtrl.addListener(_markDirty);
    _imageHandler = ImageSourceHandler(
      setState: setState,
      isMounted: () => mounted,
      onImagePicked: (path, thumb) {
        _imageHandler.deleteTempImages();
        _imagePath = path;
        _imageThumbnailPath = thumb;
        _isDirty = true;
      },
      onImageRemoved: () {
        _imageHandler.deleteTempImages();
        _imagePath = null;
        _imageUrl = null;
        _imageThumbnailPath = null;
        _isDirty = true;
      },
      tempImagePaths: _tempImagePaths,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final categories = context.read<CategoryBloc>().state.categories;
      if (categories.isNotEmpty) {
        _tryLookupCategory(categories);
      }
    });
  }

  void _markDirty() => _isDirty = true;

  void _tryLookupCategory(List<Category> categories) {
    if (_selectedCategory != null) return;
    final catId = widget.product?.categoryId;
    if (catId == null || catId.isEmpty) return;
    final found = categories.where((c) => c.id == catId).firstOrNull;
    if (found != null) {
      setState(() => _selectedCategory = found);
    }
  }

  @override
  void dispose() {
    _imageHandler.deleteTempImages();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_submitted) return;
    _submitted = true;
    _isDirty = false;
    final bloc = context.read<ProductBloc>();
    final price = double.tryParse(_priceCtrl.text);
    final stock = _resolveStock();
    final cost = double.tryParse(_costCtrl.text);
    if (price == null) {
      _submitted = false;
      return;
    }
    final sku = _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim();
    final barcode = _barcodeCtrl.text.trim().isEmpty
        ? null
        : _barcodeCtrl.text.trim();

    if (_isEditing) {
      bloc.add(
        ProductUpdated(
          widget.product!.copyWith(
            name: _nameCtrl.text.trim(),
            price: price,
            stock: stock,
            sku: sku,
            barcode: barcode,
            cost: cost,
            categoryId: _selectedCategory?.id,
            imagePath: _imagePath,
            imageUrl: _imageUrl,
            imageThumbnailPath: _imageThumbnailPath,
            isActive: _isActive,
            trackStock: _trackStock,
          ),
        ),
      );
    } else {
      bloc.add(
        ProductAdded(
          name: _nameCtrl.text.trim(),
          price: price,
          stock: stock,
          sku: sku,
          barcode: barcode,
          categoryId: _selectedCategory?.id,
          imagePath: _imagePath,
          imageUrl: _imageUrl,
          imageThumbnailPath: _imageThumbnailPath,
          trackStock: _trackStock,
        ),
      );
    }
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
          listener: (ctx, state) => _tryLookupCategory(state.categories),
        ),
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) =>
              (_submitted || _deleting) && prev.saveStatus != curr.saveStatus,
          listener: (ctx, state) {
            if (state.saveStatus == ProductSaveStatus.saved) {
              Navigator.pop(ctx, true);
            } else if (state.saveStatus == ProductSaveStatus.error) {
              _submitted = false;
              _deleting = false;
              final msg = switch (state.errorMessage) {
                'duplicateBarcode' => ctx.l10n.duplicateBarcode,
                'productAddError' => ctx.l10n.productAddError,
                'productUpdateError' => ctx.l10n.productUpdateError,
                'productDeleteError' => ctx.l10n.productDeleteError,
                _ => ctx.l10n.errorOccurred,
              };
              AppSnackBar.error(ctx, msg);
            }
          },
        ),
      ],
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (!_isDirty || _submitted || _deleting) {
            if (!context.mounted) return;
            Navigator.of(context).pop();
            return;
          }
          final shouldPop = await showUnsavedChangesDialog(context);
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                _isEditing
                    ? context.l10n.editProductTitle
                    : context.l10n.addProduct,
              ),
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: const Icon(Icons.badge_outlined),
                    text: context.l10n.tabInfo,
                  ),
                  Tab(
                    icon: const Icon(Icons.sell_outlined),
                    text: context.l10n.tabPrice,
                  ),
                  Tab(
                    icon: const Icon(Icons.inventory_2_outlined),
                    text: context.l10n.tabStock,
                  ),
                  Tab(
                    icon: const Icon(Icons.settings_outlined),
                    text: context.l10n.settingsTitle,
                  ),
                ],
                isScrollable: true,
                tabAlignment: TabAlignment.start,
              ),
            ),
            bottomNavigationBar: BlocBuilder<ProductBloc, ProductState>(
              builder: (_, state) {
                final isSaving = state.saveStatus == ProductSaveStatus.saving;
                return StickyActionBar(
                  primaryLabel: _isEditing
                      ? context.l10n.save
                      : context.l10n.addProduct,
                  onPrimary: _submit,
                  dangerLabel: _isEditing ? context.l10n.delete : null,
                  onDanger: _isEditing ? _confirmDelete : null,
                  isLoading: isSaving,
                );
              },
            ),
            body: ProductEditTabView(
              product: widget.product,
              formKey: _formKey,
              nameCtrl: _nameCtrl,
              priceCtrl: _priceCtrl,
              stockCtrl: _stockCtrl,
              skuCtrl: _skuCtrl,
              barcodeCtrl: _barcodeCtrl,
              costCtrl: _costCtrl,
              selectedCategory: _selectedCategory,
              imagePath: _imagePath,
              imageUrl: _imageUrl,
              isActive: _isActive,
              trackStock: _trackStock,
              isPickingImage: _imageHandler.isPickingImage,
              isGeneratingBarcode: _isGeneratingBarcode,
              onCategoryChanged: (cat) {
                _markDirty();
                setState(() => _selectedCategory = cat);
              },
              onImageTap: () {
                _imageHandler.showSheet(
                  context,
                  hasImage: _imagePath != null || _imageUrl != null,
                  productId: 'new',
                  logTag: 'ProductFormPage',
                );
              },
              onActiveChanged: (v) {
                _markDirty();
                setState(() => _isActive = v);
              },
              onTrackStockChanged: (v) {
                _markDirty();
                setState(() => _trackStock = v);
              },
              onStockChanged: (v) {
                _markDirty();
                setState(() => _stockCtrl.text = v.toString());
              },
              onDelete: _confirmDelete,
              onGenerateBarcode: _generateBarcode,
            ),
          ),
        ),
      ),
    );
  }

  int _resolveStock() {
    if (_trackStock) return int.tryParse(_stockCtrl.text) ?? 0;
    if (_isEditing) return widget.product!.stock;
    return int.tryParse(_stockCtrl.text) ?? 0;
  }

  void _confirmDelete() async {
    final confirmed = await showConfirmDeleteDialog(
      context,
      widget.product!.name,
    );
    if (!mounted || !confirmed) return;
    _deleting = true;
    _isDirty = false;
    context.read<ProductBloc>().add(ProductDeleted(widget.product!.id));
  }

  Future<void> _generateBarcode() async {
    final l10n = context.l10n;
    final settings = context.read<SettingsCubit>().state.settings;
    final prefix = settings.barcodeAutoGeneratePrefix;
    setState(() => _isGeneratingBarcode = true);
    try {
      final generateBarcode = sl<GenerateBarcode>();
      final barcode = await generateBarcode(
        prefix: prefix,
        excludeId: widget.product?.id,
      );
      if (!mounted) return;
      _barcodeCtrl.text = barcode;
      _markDirty();
      AppSnackBar.success(context, l10n.barcodeGenerated);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, l10n.errorOccurred);
    } finally {
      if (mounted) setState(() => _isGeneratingBarcode = false);
    }
  }
}
