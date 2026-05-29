import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_text_field.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form_avatar.dart';

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
  late final _categoryCtrl = TextEditingController(
    text: widget.product?.category ?? '',
  );
  String? _imagePath;
  String? _imageUrl;
  late bool _isActive;
  late bool _trackStock;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _isActive = widget.product?.isActive ?? true;
    _trackStock = widget.product?.trackStock ?? true;
    _imagePath = widget.product?.imagePath;
    _imageUrl = widget.product?.imageUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  bool _submitted = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_submitted) return;
    _submitted = true;
    final bloc = context.read<ProductBloc>();
    if (_isEditing) {
      bloc.add(
        ProductUpdated(
          widget.product!.copyWith(
            name: _nameCtrl.text.trim(),
            price: double.parse(_priceCtrl.text),
            stock: int.parse(_stockCtrl.text),
            category: _categoryCtrl.text.trim().isEmpty
                ? null
                : _categoryCtrl.text.trim(),
            imagePath: _imagePath,
            imageUrl: _imageUrl,
            isActive: _isActive,
            trackStock: _trackStock,
          ),
        ),
      );
    } else {
      bloc.add(
        ProductAdded(
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text),
          stock: int.parse(_stockCtrl.text),
          category: _categoryCtrl.text.trim().isEmpty
              ? null
              : _categoryCtrl.text.trim(),
          imagePath: _imagePath,
          imageUrl: _imageUrl,
          trackStock: _trackStock,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

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
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
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
                  onChanged: (_) => setState(() {}),
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

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ProductFormAvatar(
                          imagePath: _imagePath,
                          imageUrl: _imageUrl,
                          onTap: () => _showImageSourceSheet(context),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditing
                                    ? context.l10n.editProductTitle
                                    : context.l10n.addProduct,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ProductSectionLabel(
                      label: context.l10n.productFormSectionBasicInfo,
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
                    ProductSectionLabel(
                      label: context.l10n.productFormSectionDetails,
                    ),
                    const SizedBox(height: 8),
                    ProductTextField(
                      controller: _categoryCtrl,
                      labelText: context.l10n.categoryLabel,
                      icon: Icons.category_outlined,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      value: _trackStock,
                      onChanged: (value) => setState(() => _trackStock = value),
                      title: Text(context.l10n.trackStock),
                      subtitle: Text(context.l10n.trackStockHint),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 4),
                      SwitchListTile(
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        title: Text(context.l10n.showProduct),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
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
                              : Icon(
                                  _isEditing ? Icons.save_outlined : Icons.add,
                                ),
                          label: Text(
                            _isEditing
                                ? context.l10n.save
                                : context.l10n.addProduct,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceSheet(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
    if (result == null || !mounted) return;

    final imageService = GetIt.I<ProductImageService>();
    final productId = _isEditing ? widget.product!.id : 'new';

    if (result == 'gallery') {
      final path = await imageService.pickFromGallery(productId);
      if (path != null && mounted) setState(() => _imagePath = path);
    } else if (result == 'camera') {
      final path = await imageService.pickFromCamera(productId);
      if (path != null && mounted) setState(() => _imagePath = path);
    } else if (result == 'remove') {
      await imageService.deleteImage(_imagePath);
      if (mounted) {
        setState(() {
          _imagePath = null;
          _imageUrl = null;
        });
      }
    }
  }
}
