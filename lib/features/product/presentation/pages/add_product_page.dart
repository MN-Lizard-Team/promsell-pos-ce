import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/category_picker_page.dart';
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
  String? _imagePath;
  String? _imageThumbnailPath;
  bool _trackStock = true;
  Category? _selectedCategory;
  bool _isPickingImage = false;
  bool _submitted = false;
  bool _isDirty = false;

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
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _markDirty() => _isDirty = true;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_submitted) return;
    _submitted = true;

    final price = double.tryParse(_priceCtrl.text);
    final stock = int.tryParse(_stockCtrl.text);
    if (price == null || stock == null) return;

    context.read<ProductBloc>().add(
      ProductAdded(
        name: _nameCtrl.text.trim(),
        price: price,
        stock: stock,
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
          'categoryId': _selectedCategory?.id,
          'categoryName': _selectedCategory?.name,
          'imagePath': _imagePath,
          'imageThumbnailPath': _imageThumbnailPath,
          'trackStock': _trackStock,
        });
      }
      return true;
    } else if (result == 'discard') {
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
    _imagePath = draft['imagePath'] as String?;
    _imageThumbnailPath = draft['imageThumbnailPath'] as String?;
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
    final theme = Theme.of(context);
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
            AppSnackBar.error(
              ctx,
              state.errorMessage ?? ctx.l10n.errorOccurred,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.addProductTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: _submit,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useTwoColumns = constraints.maxWidth >= 420;
                  final priceField = ProductTextField(
                    controller: _priceCtrl,
                    labelText: context.l10n.priceLabel(currency),
                    icon: Icons.sell_outlined,
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
                        return context.l10n.priceRequired;
                      }
                      final parsed = double.tryParse(value);
                      if (parsed == null || parsed <= 0) {
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
                              onTap: () => _showImageSourceSheet(context),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                context.l10n.addProductTitle,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.l10n.productFormSectionBasicInfo,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ProductTextField(
                          controller: _nameCtrl,
                          labelText: context.l10n.productNameLabel,
                          icon: Icons.badge_outlined,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
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
                        const SizedBox(height: 20),
                        Text(
                          context.l10n.productFormSectionDetails,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCategoryField(context),
                        const SizedBox(height: 4),
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
                        const SizedBox(height: 20),
                        BlocBuilder<ProductBloc, ProductState>(
                          builder: (_, state) {
                            final isSaving =
                                state.saveStatus == ProductSaveStatus.saving;
                            return FilledButton.icon(
                              onPressed: isSaving ? null : _submit,
                              icon: isSaving
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.add),
                              label: Text(context.l10n.addProduct),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
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
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPickerPage(selectedId: _selectedCategory?.id),
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCategory = result;
        _markDirty();
      });
    }
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
              if (_imagePath != null)
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

    if (result == 'gallery') {
      setState(() => _isPickingImage = true);
      final path = await imageService.pickFromGallery('new');
      if (path != null && mounted) {
        final thumbPath = await imageService.generateThumbnail(path);
        setState(() {
          _imagePath = path;
          _imageThumbnailPath = thumbPath;
          _isPickingImage = false;
          _markDirty();
        });
      } else if (mounted) {
        setState(() => _isPickingImage = false);
      }
    } else if (result == 'camera') {
      setState(() => _isPickingImage = true);
      final path = await imageService.pickFromCamera('new');
      if (path != null && mounted) {
        final thumbPath = await imageService.generateThumbnail(path);
        setState(() {
          _imagePath = path;
          _imageThumbnailPath = thumbPath;
          _isPickingImage = false;
          _markDirty();
        });
      } else if (mounted) {
        setState(() => _isPickingImage = false);
      }
    } else if (result == 'remove') {
      setState(() {
        _imagePath = null;
        _imageThumbnailPath = null;
        _markDirty();
      });
    }
  }
}
