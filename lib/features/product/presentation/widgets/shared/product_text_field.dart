import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.onChanged,
    this.suffix,
    this.focusNode,
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
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        helperText: helperText,
        helperMaxLines: 2,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
    );
  }
}
