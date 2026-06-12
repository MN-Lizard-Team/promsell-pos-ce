import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/image_source_sheet.dart';
import 'package:promsell_pos_ce/core/widgets/sticky_action_bar.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_picker_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form_avatar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _skuCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  String? _imagePath;
  String? _imageThumbnailPath;
  bool _trackStock = true;
  Category? _selectedCategory;
  bool _isPickingImage = false;
  bool _submitted = false;
  bool _isDirty = false;
  final List<String> _tempImagePaths = [];

  @override
  void initState() {
    super.initState();
    _checkDraft();
  }

  void _checkDraft() {
    final draftCubit = context.read<AddProductDraftCubit>();
    final draft = draftCubit.loadDraft();
    if (draft != null && draft.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRestoreDraftDialog(draft);
      });
    }
  }

  @override
  void dispose() {
    _deleteTempImages();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _skuCtrl.dispose();
    _barcodeCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _deleteTempImages() {
    for (final path in _tempImagePaths) {
      try {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}
    }
    _tempImagePaths.clear();
  }

  void _markDirty() => _isDirty = true;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_submitted) return;
    _submitted = true;

    final price = double.tryParse(_priceCtrl.text);
    final stock = int.tryParse(_stockCtrl.text);
    final cost = double.tryParse(_costCtrl.text);
    if (price == null || stock == null) return;

    context.read<ProductBloc>().add(
      ProductAdded(
        name: _nameCtrl.text.trim(),
        price: price,
        stock: stock,
        sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
        barcode: _barcodeCtrl.text.trim().isEmpty
            ? null
            : _barcodeCtrl.text.trim(),
        cost: cost,
        categoryId: _selectedCategory?.id,
        imagePath: _imagePath,
        imageThumbnailPath: _imageThumbnailPath,
        trackStock: _trackStock,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty || _submitted) return true;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.saveDraft),
        content: Text(context.l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            child: Text(context.l10n.discardDraft),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'save'),
            child: Text(context.l10n.saveDraft),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );

    if (result == 'save') {
      if (mounted) {
        context.read<AddProductDraftCubit>().saveDraft({
          'name': _nameCtrl.text,
          'price': _priceCtrl.text,
          'stock': _stockCtrl.text,
          'sku': _skuCtrl.text,
          'barcode': _barcodeCtrl.text,
          'cost': _costCtrl.text,
          'categoryId': _selectedCategory?.id,
          'categoryName': _selectedCategory?.name,
          'imagePath': _imagePath,
          'imageThumbnailPath': _imageThumbnailPath,
          'trackStock': _trackStock,
        });
      }
      return true;
    } else if (result == 'discard') {
      _deleteTempImages();
      if (mounted) {
        context.read<AddProductDraftCubit>().clearDraft();
      }
      return true;
    }
    return false;
  }

  void _restoreDraft(Map<String, dynamic> draft) {
    _nameCtrl.text = draft['name'] as String? ?? '';
    _priceCtrl.text = draft['price'] as String? ?? '';
    _stockCtrl.text = draft['stock'] as String? ?? '0';
    _skuCtrl.text = draft['sku'] as String? ?? '';
    _barcodeCtrl.text = draft['barcode'] as String? ?? '';
    _costCtrl.text = draft['cost'] as String? ?? '';
    final catId = draft['categoryId'] as String?;
    final catName = draft['categoryName'] as String?;
    if (catId != null && catName != null) {
      _selectedCategory = Category(
        id: catId,
        name: catName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    final draftImagePath = draft['imagePath'] as String?;
    final draftThumbPath = draft['imageThumbnailPath'] as String?;
    if (draftImagePath != null && File(draftImagePath).existsSync()) {
      _imagePath = draftImagePath;
      if (draftThumbPath != null && File(draftThumbPath).existsSync()) {
        _imageThumbnailPath = draftThumbPath;
      }
    } else if (draftImagePath != null) {
      _imagePath = null;
      _imageThumbnailPath = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) AppSnackBar.info(context, context.l10n.imageNotFound);
      });
    }
    _trackStock = draft['trackStock'] as bool? ?? true;
    setState(() {});
  }

  void _showRestoreDraftDialog(Map<String, dynamic> draft) {
    final name = draft['name'] as String?;
    final price = draft['price'] as num?;
    final categoryName = draft['categoryName'] as String?;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.restoreDraft),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (name != null && name.isNotEmpty)
              Text('${context.l10n.productNameLabel}: $name'),
            if (price != null)
              Text(
                '${context.l10n.priceLabel('')}: \${price.toStringAsFixed(2)}',
              ),
            if (categoryName != null && categoryName.isNotEmpty)
              Text('${context.l10n.categoryLabel}: $categoryName'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AddProductDraftCubit>().clearDraft();
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.discardDraft),
          ),
          FilledButton(
            onPressed: () {
              _restoreDraft(draft);
              context.read<AddProductDraftCubit>().clearDraft();
              Navigator.pop(ctx);
            },
            child: Text(context.l10n.restore),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (!canPop) return;
        if (!context.mounted) return;
        Navigator.of(context).pop();
      },
      child: BlocListener<ProductBloc, ProductState>(
        listenWhen: (prev, curr) =>
            _submitted && prev.saveStatus != curr.saveStatus,
        listener: (ctx, state) {
          if (state.saveStatus == ProductSaveStatus.saved) {
            context.read<AddProductDraftCubit>().clearDraft();
            Navigator.pop(ctx, true);
          } else if (state.saveStatus == ProductSaveStatus.error) {
            _submitted = false;
            final msg = state.errorMessage == 'duplicateBarcode'
                ? ctx.l10n.duplicateBarcode
                : state.errorMessage ?? ctx.l10n.errorOccurred;
            AppSnackBar.error(ctx, msg);
          }
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.addProductTitle),
              bottom: TabBar(
                tabs: [
                  Tab(text: context.l10n.basic),
                  Tab(text: context.l10n.advanced),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildBasicTab(context, currency),
                        _buildAdvancedTab(context, currency),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (_, state) {
                        final isSaving =
                            state.saveStatus == ProductSaveStatus.saving;
                        return StickyActionBar(
                          primaryLabel: context.l10n.addProduct,
                          isLoading: isSaving,
                          onPrimary: isSaving ? null : _submit,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicTab(BuildContext context, String currency) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 420;
        final priceField = ProductTextField(
          controller: _priceCtrl,
          labelText: context.l10n.priceLabel(currency),
          icon: Icons.sell_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.priceRequired;
            }
            final parsed = double.tryParse(value);
            if (parsed == null || parsed < 0) {
              return context.l10n.invalidPrice;
            }
            return null;
          },
          onChanged: (_) => _markDirty(),
        );
        final stockField = ProductTextField(
          controller: _stockCtrl,
          labelText: context.l10n.quantityLabel,
          icon: Icons.inventory_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          helperText: (int.tryParse(_stockCtrl.text) ?? -1) == 0
              ? context.l10n.stockZeroWarning
              : null,
          onChanged: (_) {
            _markDirty();
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.l10n.quantityRequired;
            }
            if (int.tryParse(value) == null) {
              return context.l10n.invalidQuantity;
            }
            return null;
          },
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ProductFormAvatar(
                    imagePath: _imagePath,
                    isLoading: _isPickingImage,
                    onTap: () => _showImageSourceSheet(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      context.l10n.addProductTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.imageHelper,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ProductTextField(
                controller: _nameCtrl,
                labelText: context.l10n.productNameLabel,
                icon: Icons.badge_outlined,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? context.l10n.productNameRequired
                    : null,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _markDirty(),
              ),
              const SizedBox(height: 10),
              if (useTwoColumns)
                Row(
                  children: [
                    Expanded(child: priceField),
                    const SizedBox(width: 12),
                    Expanded(child: stockField),
                  ],
                )
              else ...[
                priceField,
                const SizedBox(height: 10),
                stockField,
              ],
              const SizedBox(height: 10),
              _buildCategoryField(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedTab(BuildContext context, String currency) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProductTextField(
            controller: _barcodeCtrl,
            labelText: context.l10n.barcodeLabel,
            helperText: context.l10n.barcodeHelper,
            icon: Icons.qr_code_scanner_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _markDirty(),
            suffix: IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              tooltip: context.l10n.scanBarcode,
              onPressed: () => _scanBarcode(context),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _generateBarcode(context),
              icon: const Icon(Icons.auto_fix_high_outlined, size: 18),
              label: Text(context.l10n.generateBarcode),
            ),
          ),
          const SizedBox(height: 10),
          ProductTextField(
            controller: _skuCtrl,
            labelText: context.l10n.skuLabel,
            helperText: context.l10n.skuHelper,
            icon: Icons.tag_outlined,
            textInputAction: TextInputAction.next,
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 10),
          ProductTextField(
            controller: _costCtrl,
            labelText: context.l10n.costLabel(currency),
            icon: Icons.price_change_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: _trackStock,
            onChanged: (value) {
              setState(() => _trackStock = value);
              _markDirty();
            },
            title: Text(context.l10n.trackStock),
            subtitle: Text(context.l10n.trackStockHint),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    final barcode = await showProductBarcodeScanner(
      context,
      beepOnScan: GetIt.I<SettingsCubit>().state.settings.barcodeBeepOnScan,
    );
    if (barcode != null && barcode.isNotEmpty) {
      setState(() => _barcodeCtrl.text = barcode);
      _markDirty();
    }
  }

  void _generateBarcode(BuildContext context) {
    final prefix =
        GetIt.I<SettingsCubit>().state.settings.barcodeAutoGeneratePrefix;
    final now = DateTime.now();
    final base = now.millisecondsSinceEpoch % 10000000000;
    final barcode = base.toString().padLeft(10, '0');
    setState(() => _barcodeCtrl.text = '$prefix$barcode');
    _markDirty();
    AppSnackBar.success(context, context.l10n.barcodeGenerated);
  }

  Widget _buildCategoryField(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _pickCategory(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedCategory?.name ?? context.l10n.noCategorySelected,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _selectedCategory == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _pickCategory(BuildContext context) async {
    final bloc = GetIt.I<CategoryBloc>();
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: CategoryPickerBottomSheet(selectedId: _selectedCategory?.id),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategory = result.id.isEmpty ? null : result;
        _markDirty();
      });
    }
  }

  Future<void> _showImageSourceSheet() async {
    final l10n = context.l10n;
    final action = await showImageSourceSheet(
      context,
      hasImage: _imagePath != null,
    );
    if (action == null || !mounted) return;

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
        _imageThumbnailPath = null;
        _markDirty();
      });
      return;
    }

    final imageService = GetIt.I<ProductImageService>();

    setState(() => _isPickingImage = true);
    try {
      final path = action == ImageSourceAction.gallery
          ? await imageService.pickFromGallery('new')
          : await imageService.pickFromCamera('new');
      if (path == null) {
        setState(() => _isPickingImage = false);
        return;
      }
      final thumbPath = await imageService.generateThumbnail(path);
      if (!mounted) return;
      _deleteTempImages();
      setState(() {
        _imagePath = path;
        _imageThumbnailPath = thumbPath;
        _isPickingImage = false;
        _markDirty();
      });
      _tempImagePaths.add(path);
      if (thumbPath != null) _tempImagePaths.add(thumbPath);
      if (!mounted) return;
      AppSnackBar.success(context, l10n.imagePicked);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPickingImage = false);
      if (!mounted) return;
      AppSnackBar.error(context, l10n.imagePickFailed);
      AppLogger.error('AddProductPage image pick failed', error: e);
    }
  }
}
