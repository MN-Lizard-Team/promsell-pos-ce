import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({super.key, this.category});
  final Category? category;

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(
    text: widget.category?.name ?? '',
  );
  String? _selectedColor = _presetColors.first;
  String? _selectedIcon = _presetIcons.first.value;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _selectedColor = widget.category!.color ?? _presetColors.first;
      _selectedIcon = widget.category!.iconName ?? _presetIcons.first.value;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        _isEditing ? context.l10n.editCategory : context.l10n.addCategory,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: context.l10n.categoryName,
                  prefixIcon: const Icon(Icons.folder_outlined),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.l10n.categoryNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.categoryColor,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetColors.map((hex) {
                  final color = Color(int.parse('FF$hex', radix: 16));
                  final selected = _selectedColor == hex;
                  return Semantics(
                    label: 'Color $hex',
                    button: true,
                    child: InkWell(
                      onTap: () => setState(() => _selectedColor = hex),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: theme.colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: selected
                            ? Icon(
                                Icons.check,
                                size: 18,
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.categoryIcon,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presetIcons.map((item) {
                  final selected = _selectedIcon == item.value;
                  return Semantics(
                    label: item.value,
                    button: true,
                    child: InkWell(
                      onTap: () => setState(() => _selectedIcon = item.value),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: selected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                CategoryFormResult(
                  name: _nameCtrl.text.trim(),
                  sortOrder: widget.category?.sortOrder ?? 0,
                  color: _selectedColor,
                  iconName: _selectedIcon,
                ),
              );
            }
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

const _presetColors = [
  'E53935', // red
  'FB8C00', // orange
  'FDD835', // yellow
  '43A047', // green
  '1E88E5', // blue
  '8E24AA', // purple
  'D81B60', // pink
  '6D4C41', // brown
  '546E7A', // blueGrey
  '212121', // dark
];

const _presetIcons = [
  _IconItem(Icons.folder_outlined, 'folder_outlined'),
  _IconItem(Icons.restaurant_outlined, 'restaurant_outlined'),
  _IconItem(Icons.shopping_basket_outlined, 'shopping_basket_outlined'),
  _IconItem(Icons.local_drink_outlined, 'local_drink_outlined'),
  _IconItem(Icons.cake_outlined, 'cake_outlined'),
  _IconItem(Icons.local_cafe_outlined, 'local_cafe_outlined'),
  _IconItem(Icons.fastfood_outlined, 'fastfood_outlined'),
  _IconItem(Icons.local_pizza_outlined, 'local_pizza_outlined'),
  _IconItem(Icons.icecream_outlined, 'icecream_outlined'),
  _IconItem(Icons.kitchen_outlined, 'kitchen_outlined'),
  _IconItem(Icons.checkroom_outlined, 'checkroom_outlined'),
  _IconItem(Icons.smartphone_outlined, 'smartphone_outlined'),
  _IconItem(Icons.computer_outlined, 'computer_outlined'),
  _IconItem(Icons.chair_outlined, 'chair_outlined'),
  _IconItem(Icons.pets_outlined, 'pets_outlined'),
  _IconItem(Icons.sports_soccer_outlined, 'sports_soccer_outlined'),
  _IconItem(Icons.brush_outlined, 'brush_outlined'),
  _IconItem(Icons.local_hospital_outlined, 'local_hospital_outlined'),
  _IconItem(Icons.school_outlined, 'school_outlined'),
  _IconItem(Icons.build_outlined, 'build_outlined'),
  _IconItem(Icons.more_horiz_outlined, 'more_horiz_outlined'),
];

class _IconItem {
  const _IconItem(this.icon, this.value);
  final IconData icon;
  final String value;
}

class CategoryFormResult {
  const CategoryFormResult({
    required this.name,
    required this.sortOrder,
    this.color,
    this.iconName,
  });
  final String name;
  final int sortOrder;
  final String? color;
  final String? iconName;
}
