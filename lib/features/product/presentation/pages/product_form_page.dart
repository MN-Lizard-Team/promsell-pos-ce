import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_source_sheet.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_draft.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/generate_barcode.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_form_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/confirm_delete_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/product_form_view.dart';
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
  bool _isPickingImage = false;
  bool _isGeneratingBarcode = false;
  final _barcodeFocusNode = FocusNode();
  final List<String> _tempImagePaths = [];
  Timer? _debounceTimer;
  Timer? _submitTimeoutTimer;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _tryLookupCategory();
      _checkDraft();
    });
  }

  void _markDirty() {
    _isDirty = true;
    setState(() {});
    if (_isEditing || _submitted) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _isEditing || _submitted) return;
      _syncDraftToCubit();
      final cubit = context.read<ProductFormCubit>();
      if (cubit.draft.isEmpty) return;
      cubit.saveDraftToStorage();
    });
  }

  void _tryLookupCategory() {
    final categories = context.read<CategoryBloc>().state.categories;
    if (categories.isEmpty || _selectedCategory != null) return;
    final catId = widget.product?.categoryId;
    if (catId == null || catId.isEmpty) return;
    final found = categories.where((c) => c.id == catId).firstOrNull;
    if (found != null) {
      setState(() => _selectedCategory = found);
    }
  }

  Future<void> _checkDraft() async {
    if (_isEditing) return;
    final cubit = context.read<ProductFormCubit>();
    await cubit.draftLoaded;
    if (!mounted) return;
    final draft = cubit.draft;
    if (draft.isEmpty) return;

    _showRestoreDialog(draft);
  }

  void _showRestoreDialog(ProductDraft draft) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.restoreDraft),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (draft.name.isNotEmpty)
              Text('${l10n.productNameLabel}: ${draft.name}'),
            if (draft.price.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${l10n.priceLabel('')}: ${draft.price}'),
            ],
            if (draft.categoryName != null &&
                draft.categoryName!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('${l10n.categoryLabel}: ${draft.categoryName}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<ProductFormCubit>().clearDraft();
              Navigator.pop(ctx);
            },
            child: Text(l10n.discardDraft),
          ),
          FilledButton(
            onPressed: () {
              _debounceTimer?.cancel();
              _restoreDraft(draft);
              Navigator.pop(ctx);
            },
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
  }

  void _restoreDraft(ProductDraft draft) {
    _nameCtrl.text = draft.name;
    _priceCtrl.text = draft.price;
    _stockCtrl.text = draft.stock;
    _skuCtrl.text = draft.sku;
    _barcodeCtrl.text = draft.barcode;
    _costCtrl.text = draft.cost;
    _trackStock = draft.trackStock;
    _isActive = draft.isActive;

    if (draft.categoryId != null && draft.categoryName != null) {
      _selectedCategory = Category(
        id: draft.categoryId!,
        name: draft.categoryName!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    ProductDraft effectiveDraft = draft;
    if (draft.imagePath != null && File(draft.imagePath!).existsSync()) {
      _imagePath = draft.imagePath;
      _imageThumbnailPath = draft.imageThumbnailPath;
    } else if (draft.imagePath != null) {
      _imagePath = null;
      _imageThumbnailPath = null;
      effectiveDraft = draft.copyWith(
        imagePath: null,
        imageThumbnailPath: null,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AppSnackBar.info(context, context.l10n.imageNotFound);
      });
    }

    context.read<ProductFormCubit>().restoreDraft(effectiveDraft);
    setState(() {});
  }

  void _syncDraftToCubit() {
    final cubit = context.read<ProductFormCubit>();
    cubit.syncDraftFromControllers(
      name: _nameCtrl.text,
      price: _priceCtrl.text,
      stock: _stockCtrl.text,
      sku: _skuCtrl.text,
      barcode: _barcodeCtrl.text,
      cost: _costCtrl.text,
      categoryId: _selectedCategory?.id,
      categoryName: _selectedCategory?.name,
      imagePath: _imagePath,
      imageThumbnailPath: _imageThumbnailPath,
      trackStock: _trackStock,
      isActive: _isActive,
    );
  }

  @override
  void dispose() {
    _nameCtrl.removeListener(_markDirty);
    _priceCtrl.removeListener(_markDirty);
    _stockCtrl.removeListener(_markDirty);
    _skuCtrl.removeListener(_markDirty);
    _barcodeCtrl.removeListener(_markDirty);
    _costCtrl.removeListener(_markDirty);
    _deleteTempImages();
    _debounceTimer?.cancel();
    _submitTimeoutTimer?.cancel();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _barcodeFocusNode.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _deleteTempImages() {
    for (final path in _tempImagePaths) {
      try {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      } catch (e) {
        AppLogger.warning('Failed to delete temp image: $path', error: e);
      }
    }
    _tempImagePaths.clear();
  }

  void _submit() {
    final bloc = context.read<ProductBloc>();
    if (_submitted || bloc.state.saveStatus == ProductSaveStatus.saving) return;
    if (!_formKey.currentState!.validate()) return;
    _submitted = true;
    _isDirty = false;
    setState(() {});
    _submitTimeoutTimer?.cancel();
    _submitTimeoutTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || !_submitted) return;
      _submitted = false;
      setState(() {});
      AppSnackBar.error(context, context.l10n.errorOccurred);
    });
    final price = double.tryParse(_priceCtrl.text);
    final stock = _resolveStock();
    final cost = double.tryParse(_costCtrl.text);
    if (price == null) {
      _submitted = false;
      setState(() {});
      return;
    }
    final sku = _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim();
    final barcode = _barcodeCtrl.text.trim().isEmpty
        ? null
        : _barcodeCtrl.text.trim();

    String? imagePath = _imagePath;
    String? imageThumbnailPath = _imageThumbnailPath;
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        !File(imagePath).existsSync()) {
      imagePath = null;
      imageThumbnailPath = null;
      AppLogger.warning(
        'Image file not found at submit, clearing path: $_imagePath',
      );
    }

    if (_isEditing) {
      final latest = bloc.state.products
          .where((p) => p.id == widget.product!.id)
          .firstOrNull;
      final base = latest ?? widget.product!;
      final categoryId =
          _selectedCategory?.id ??
          (_selectedCategory == null && base.categoryId != null
              ? base.categoryId
              : null);
      bloc.add(
        ProductUpdated(
          base.copyWith(
            name: _nameCtrl.text.trim(),
            price: price,
            stock: stock,
            sku: sku,
            barcode: barcode,
            cost: cost,
            categoryId: categoryId,
            imagePath: imagePath,
            imageUrl: _imageUrl,
            imageThumbnailPath: imageThumbnailPath,
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
          cost: cost,
          categoryId: _selectedCategory?.id,
          imageUrl: _imageUrl,
          imagePath: imagePath,
          imageThumbnailPath: imageThumbnailPath,
          trackStock: _trackStock,
        ),
      );
    }
  }

  int _resolveStock() {
    if (_trackStock) return int.tryParse(_stockCtrl.text) ?? 0;
    if (_isEditing) {
      final bloc = context.read<ProductBloc>();
      final latest = bloc.state.products
          .where((p) => p.id == widget.product!.id)
          .firstOrNull;
      return latest?.stock ?? widget.product!.stock;
    }
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
      _barcodeCtrl.text = barcode.toUpperCase();
      _markDirty();
      _barcodeFocusNode.requestFocus();
      AppSnackBar.success(context, l10n.barcodeGenerated);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, l10n.errorOccurred);
    } finally {
      if (mounted) setState(() => _isGeneratingBarcode = false);
    }
  }

  Future<void> _onImageTap() async {
    final l10n = context.l10n;
    final imageService = sl<ProductImageService>();
    final hasImage = _imagePath != null || _imageUrl != null;

    final action = await showImageSourceSheet(context, hasImage: hasImage);
    if (action == null || !mounted) return;

    if (action == ImageSourceAction.remove) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.removeImage),
          content: Text(l10n.removeImageConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.removeImage),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      _deleteTempImages();
      setState(() {
        _imagePath = null;
        _imageUrl = null;
        _imageThumbnailPath = null;
        _isDirty = true;
      });
      return;
    }

    setState(() => _isPickingImage = true);
    try {
      final path = action == ImageSourceAction.gallery
          ? await imageService.pickFromGallery('new')
          : await imageService.pickFromCamera('new');
      if (path != null) {
        final thumbPath = await imageService.generateThumbnail(path);
        _deleteTempImages();
        _tempImagePaths.add(path);
        if (thumbPath != null) _tempImagePaths.add(thumbPath);
        setState(() {
          _imagePath = path;
          _imageUrl = null;
          _imageThumbnailPath = thumbPath;
          _isDirty = true;
        });
        if (mounted) AppSnackBar.success(context, l10n.imagePicked);
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, l10n.imagePickFailed);
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
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
          listener: (ctx, state) => _tryLookupCategory(),
        ),
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) =>
              (_submitted || _deleting) && prev.saveStatus != curr.saveStatus,
          listener: (ctx, state) {
            if (state.saveStatus == ProductSaveStatus.saved) {
              _submitTimeoutTimer?.cancel();
              if (!_isEditing) {
                ctx.read<ProductFormCubit>().clearDraft();
              }
              AppSnackBar.success(ctx, ctx.l10n.productSaved);
              Navigator.pop(ctx, true);
            } else if (state.saveStatus == ProductSaveStatus.error) {
              _submitTimeoutTimer?.cancel();
              _submitted = false;
              _deleting = false;
              setState(() {});
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
        canPop: !_isDirty || _submitted || _deleting,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final action = await showUnsavedChangesDialog(context);
          if (action == UnsavedDialogAction.save && context.mounted) {
            _submit();
          } else if (action == UnsavedDialogAction.discard && context.mounted) {
            if (!_isEditing) {
              _syncDraftToCubit();
              final cubit = context.read<ProductFormCubit>();
              if (cubit.draft.isEmpty) {
                cubit.clearDraft();
              } else {
                cubit.saveDraftToStorage();
              }
            }
            _deleteTempImages();
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _isEditing
                  ? context.l10n.editProductTitle
                  : context.l10n.addProduct,
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
          body: ProductFormView(
            product: widget.product,
            formKey: _formKey,
            nameCtrl: _nameCtrl,
            priceCtrl: _priceCtrl,
            stockCtrl: _stockCtrl,
            skuCtrl: _skuCtrl,
            barcodeCtrl: _barcodeCtrl,
            barcodeFocusNode: _barcodeFocusNode,
            costCtrl: _costCtrl,
            selectedCategory: _selectedCategory,
            imageUrl: _imageUrl,
            imagePath: _imagePath,
            isActive: _isActive,
            trackStock: _trackStock,
            isPickingImage: _isPickingImage,
            isGeneratingBarcode: _isGeneratingBarcode,
            onCategoryChanged: (cat) {
              _markDirty();
              setState(() => _selectedCategory = cat);
            },
            onImageTap: _onImageTap,
            onActiveChanged: (v) {
              _markDirty();
              setState(() => _isActive = v);
            },
            onTrackStockChanged: (v) async {
              final bloc = context.read<ProductBloc>();
              if (!v && _trackStock) {
                final l10n = context.l10n;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.trackStock),
                    content: Text(l10n.trackStockDisableConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.confirm),
                      ),
                    ],
                  ),
                );
                if (confirmed != true || !mounted) return;
              }
              _markDirty();
              if (v &&
                  _isEditing &&
                  int.tryParse(_stockCtrl.text) == 0 &&
                  mounted) {
                final latest = bloc.state.products
                    .where((p) => p.id == widget.product!.id)
                    .firstOrNull;
                final restoreStock = latest?.stock ?? widget.product!.stock;
                if (restoreStock > 0) {
                  _stockCtrl.text = restoreStock.toString();
                }
              }
              setState(() => _trackStock = v);
            },
            onStockChanged: (v) {
              _markDirty();
              setState(() => _stockCtrl.text = v.toString());
            },
            onGenerateBarcode: _generateBarcode,
          ),
        ),
      ),
    );
  }
}
