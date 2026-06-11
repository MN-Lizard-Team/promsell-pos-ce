import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
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
      _selectedCategory = cats.firstWhere(
        (c) => c.id == catId,
        orElse: () => Category(
          id: catId,
          name: context.l10n.uncategorized,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // CategoryBloc not available in this scope; picker will handle it
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
          AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.errorOccurred);
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
          onImageTap: () => _showImageSourceSheet(context),
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

  Future<void> _showImageSourceSheet(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(l10n.pickImageGallery),
                onTap: () => Navigator.pop(ctx, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(l10n.pickImageCamera),
                onTap: () => Navigator.pop(ctx, 'camera'),
              ),
              if (_imagePath != null || _imageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.removeImage),
                  onTap: () => Navigator.pop(ctx, 'remove'),
                ),
            ],
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;

    final imageService = GetIt.I<ProductImageService>();
    final productId = _isEditing ? widget.product!.id : 'new';

    if (result == 'gallery') {
      setState(() => _isPickingImage = true);
      final path = await imageService.pickFromGallery(productId);
      if (path != null && mounted) {
        final thumbPath = await imageService.generateThumbnail(path);
        setState(() {
          _imagePath = path;
          _imageThumbnailPath = thumbPath;
          _isPickingImage = false;
        });
      } else if (mounted) {
        setState(() => _isPickingImage = false);
      }
    } else if (result == 'camera') {
      setState(() => _isPickingImage = true);
      final path = await imageService.pickFromCamera(productId);
      if (path != null && mounted) {
        final thumbPath = await imageService.generateThumbnail(path);
        setState(() {
          _imagePath = path;
          _imageThumbnailPath = thumbPath;
          _isPickingImage = false;
        });
      } else if (mounted) {
        setState(() => _isPickingImage = false);
      }
    } else if (result == 'remove') {
      if (mounted) {
        setState(() {
          _imagePath = null;
          _imageUrl = null;
          _imageThumbnailPath = null;
        });
      }
    }
  }
}
