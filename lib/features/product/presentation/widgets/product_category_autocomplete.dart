import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class ProductCategoryAutocomplete extends StatelessWidget {
  const ProductCategoryAutocomplete({
    super.key,
    required this.controller,
    required this.categories,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final List<String> categories;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        if (query.isEmpty) return categories;
        return categories
            .where((c) => c.toLowerCase().contains(query))
            .toList();
      },
      fieldViewBuilder: (_, fieldController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: context.l10n.categoryLabel,
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) {
            controller.text = fieldController.text;
            onFieldSubmitted.call();
          },
        );
      },
      onSelected: (selection) {
        controller.text = selection;
        onSubmitted?.call(selection);
      },
    );
  }
}
