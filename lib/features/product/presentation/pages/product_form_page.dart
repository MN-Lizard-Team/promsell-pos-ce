import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/image_source_sheet.dart';
import 'package:promsell_pos_ce/core/widgets/sticky_action_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_edit_tab_view.dart';

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
  Category? _selectedCategory;
  String? _imagePath;
  String? _imageUrl;
  String? _imageThumbnailPath;
  late bool _isActive;
  late bool _trackStock;
  bool _isPickingImage = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _isActive = widget.product?.isActive ?? true;
    _trackStock = widget.product?.trackStock ?? true;
    _imagePath = widget.product?.imagePath;
    _imageUrl = widget.product?.imageUrl;
    _imageThumbnailPath = widget.product?.imageThumbnailPath;
    WidgetsBinding.instance.addPostFrameCallback((_) => _lookupCategory());
  }

  void _lookupCategory() {
    if (!mounted) return;
    if (_selectedCategory != null) return;
    final catId = widget.product?.categoryId;
    if (catId == null || catId.isEmpty) return;
    try {
      final cats = context.read<CategoryBloc>().state.categories;
      final found = cats.firstWhere(
        (c) => c.id == catId,
        orElse: () => Category(
          id: catId,
          name: context.l10n.uncategorized,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      setState(() => _selectedCategory = found);
    } on ProviderNotFoundException {
      // CategoryBloc not available in this scope; picker will handle it
    } catch (e, stack) {
      AppLogger.warning(
        'ProductFormPage._lookupCategory failed',
        error: e,
        stack: stack,
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  bool _submitted = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_submitted) return;
    _submitted = true;
    final bloc = context.read<ProductBloc>();
    if (_isEditing) {
      final price = double.tryParse(_priceCtrl.text);
      final stock = int.tryParse(_stockCtrl.text);
      if (price == null || stock == null) return;
      bloc.add(
        ProductUpdated(
          widget.product!.copyWith(
            name: _nameCtrl.text.trim(),
            price: price,
            stock: stock,
            sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
            barcode: _barcodeCtrl.text.trim().isEmpty
                ? null
                : _barcodeCtrl.text.trim(),
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
      final price = double.tryParse(_priceCtrl.text);
      final stock = int.tryParse(_stockCtrl.text);
      if (price == null || stock == null) return;
      bloc.add(
        ProductAdded(
          name: _nameCtrl.text.trim(),
          price: price,
          stock: stock,
          sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
          barcode: _barcodeCtrl.text.trim().isEmpty
              ? null
              : _barcodeCtrl.text.trim(),
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
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) =>
          _submitted && prev.saveStatus != curr.saveStatus,
      listener: (ctx, state) {
        if (state.saveStatus == ProductSaveStatus.saved) {
          Navigator.pop(ctx, true);
        } else if (state.saveStatus == ProductSaveStatus.error) {
          _submitted = false;
          final msg = state.errorMessage == 'duplicateBarcode'
              ? ctx.l10n.duplicateBarcode
              : state.errorMessage ?? ctx.l10n.errorOccurred;
          AppSnackBar.error(ctx, msg);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BlocBuilder<ProductBloc, ProductState>(
          builder: (_, state) {
            final isSaving = state.saveStatus == ProductSaveStatus.saving;
            return StickyActionBar(
              primaryLabel: _isEditing
                  ? context.l10n.save
                  : context.l10n.addProduct,
              onPrimary: _submit,
              dangerLabel: _isEditing ? context.l10n.delete : null,
              onDanger: _isEditing ? () => _confirmDelete(context) : null,
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
          selectedCategory: _selectedCategory,
          imagePath: _imagePath,
          imageUrl: _imageUrl,
          isActive: _isActive,
          trackStock: _trackStock,
          isPickingImage: _isPickingImage,
          onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
          onImageTap: () => _showImageSourceSheet(),
          onActiveChanged: (v) => setState(() => _isActive = v),
          onTrackStockChanged: (v) => setState(() => _trackStock = v),
          onStockChanged: (v) => setState(() => _stockCtrl.text = v.toString()),
          onDelete: () => _confirmDelete(context),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(
          '${l10n.deleteCategoryConfirm} "${widget.product!.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<ProductBloc>().add(
                ProductDeleted(widget.product!.id),
              );
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceSheet() async {
    final l10n = context.l10n;
    final action = await showImageSourceSheet(
      context,
      hasImage: _imagePath != null || _imageUrl != null,
    );
    if (action == null) return;
    if (!mounted) return;

    if (action == ImageSourceAction.remove) {
      if (!mounted) return;
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
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      if (!mounted) return;
      setState(() {
        _imagePath = null;
        _imageUrl = null;
        _imageThumbnailPath = null;
      });
      return;
    }

    final imageService = GetIt.I<ProductImageService>();
    final productId = _isEditing ? widget.product!.id : 'new';

    setState(() => _isPickingImage = true);
    try {
      final path = action == ImageSourceAction.gallery
          ? await imageService.pickFromGallery(productId)
          : await imageService.pickFromCamera(productId);
      if (path == null) {
        setState(() => _isPickingImage = false);
        return;
      }
      final thumbPath = await imageService.generateThumbnail(path);
      if (!mounted) return;
      setState(() {
        _imagePath = path;
        _imageThumbnailPath = thumbPath;
        _isPickingImage = false;
      });
      if (!mounted) return;
      AppSnackBar.success(context, l10n.imagePicked);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPickingImage = false);
      if (!mounted) return;
      AppSnackBar.error(context, l10n.imagePickFailed);
      AppLogger.error('ProductFormPage image pick failed', error: e);
    }
  }
}
