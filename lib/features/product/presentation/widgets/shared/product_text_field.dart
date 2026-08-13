import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';

/// Product-form wrapper around [AppTextField] (dense, no prefix by default).
///
/// Keeps the historical API (`icon` + `showIcon`) so existing call sites
/// and tests (`product-text-field-clear`) stay stable.
class ProductTextField extends StatelessWidget {
  const ProductTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.helperText,
    this.hintText,
    this.onChanged,
    this.suffix,
    this.suffixText,
    this.focusNode,
    this.maxLines,
    this.maxLength,
    this.showIcon = false,
    this.showClearButton = true,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final String? helperText;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final String? suffixText;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? maxLength;
  final bool showIcon;
  final bool showClearButton;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      helperText: helperText,
      hintText: hintText,
      prefixIcon: icon,
      showPrefixIcon: showIcon,
      suffix: suffix,
      suffixText: suffixText,
      showClearButton: showClearButton,
      clearButtonKey: const ValueKey('product-text-field-clear'),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
    );
  }
}
