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
    text: widget.product?.price.toStringAsFixed(2) ?? '',
  );
  late final _stockCtrl = TextEditingController(
    text: widget.product?.stock.toString() ?? '0',
  );
  late final _categoryCtrl = TextEditingController(
    text: widget.product?.category ?? '',
  );
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
      bloc.add(
        ProductUpdated(
          widget.product!.copyWith(
            name: _nameCtrl.text.trim(),
            price: double.parse(_priceCtrl.text),
            stock: int.parse(_stockCtrl.text),
            category: _categoryCtrl.text.trim().isEmpty
                ? null
                : _categoryCtrl.text.trim(),
            isActive: _isActive,
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
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return SafeArea(
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
              final priceField = _ProductTextField(
                controller: _priceCtrl,
                labelText: context.l10n.priceLabel.replaceAll('฿', currency),
                icon: Icons.sell_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
              final stockField = _ProductTextField(
                controller: _stockCtrl,
                labelText: context.l10n.quantityLabel,
                icon: Icons.inventory_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  const SizedBox(height: 18),
                  Text(
                    _isEditing
                        ? context.l10n.editProductTitle
                        : context.l10n.addProduct,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ProductTextField(
                    controller: _nameCtrl,
                    labelText: context.l10n.productNameLabel,
                    icon: Icons.badge_outlined,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? context.l10n.productNameRequired
                        : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    stockField,
                  ],
                  const SizedBox(height: 12),
                  _ProductTextField(
                    controller: _categoryCtrl,
                    labelText: context.l10n.categoryLabel,
                    icon: Icons.category_outlined,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 8),
                    SwitchListTile(
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      title: Text(context.l10n.showProduct),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(
                      _isEditing ? context.l10n.save : context.l10n.addProduct,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductTextField extends StatelessWidget {
  const _ProductTextField({
    required this.controller,
    required this.labelText,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText, prefixIcon: Icon(icon)),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
