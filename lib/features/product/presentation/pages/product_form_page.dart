import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';

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
      text: widget.product?.price.toStringAsFixed(2) ?? '');
  late final _stockCtrl =
      TextEditingController(text: widget.product?.stock.toString() ?? '0');
  late final _categoryCtrl =
      TextEditingController(text: widget.product?.category ?? '');
  late bool _isActive;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _isActive = widget.product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final bloc = context.read<ProductBloc>();
    if (_isEditing) {
      bloc.add(ProductUpdated(
        widget.product!.copyWith(
          name: _nameCtrl.text.trim(),
          price: double.parse(_priceCtrl.text),
          stock: int.parse(_stockCtrl.text),
          category: _categoryCtrl.text.trim().isEmpty
              ? null
              : _categoryCtrl.text.trim(),
          isActive: _isActive,
        ),
      ));
    } else {
      bloc.add(ProductAdded(
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        stock: int.parse(_stockCtrl.text),
        category: _categoryCtrl.text.trim().isEmpty
            ? null
            : _categoryCtrl.text.trim(),
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? context.l10n.editProductTitle : context.l10n.addProduct,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.productNameLabel,
                border: const OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? context.l10n.productNameRequired : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.priceLabel.replaceAll(
                        '฿',
                        context
                            .watch<SettingsCubit>()
                            .state
                            .settings
                            .currency),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.l10n.priceRequired;
                      final parsed = double.tryParse(v);
                      if (parsed == null || parsed <= 0) return context.l10n.invalidPrice;
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.quantityLabel,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return context.l10n.quantityRequired;
                      if (int.tryParse(v) == null) return context.l10n.invalidQuantity;
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryCtrl,
              decoration: InputDecoration(
                labelText: context.l10n.categoryLabel,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              SwitchListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(context.l10n.showProduct),
                contentPadding: EdgeInsets.zero,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submit,
              child: Text(_isEditing ? context.l10n.save : context.l10n.addProduct),
            ),
          ],
        ),
      ),
    );
  }
}
