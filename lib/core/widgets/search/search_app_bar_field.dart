import 'package:flutter/material.dart';

/// Compact filled search field for primary-colored AppBars (Sale / Product).
///
/// Keeps icon metrics, type scale, and radius consistent so full-screen
/// search pages do not drift into oversized or mismatched chrome.
class SearchAppBarField extends StatelessWidget {
  const SearchAppBarField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showClear = false,
    this.autofocus = false,
    this.textInputAction = TextInputAction.search,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool showClear;
  final bool autofocus;
  final TextInputAction textInputAction;

  static const double _radius = 12;
  static const double _iconSize = 20;
  static const BoxConstraints _iconConstraints = BoxConstraints(
    minWidth: 40,
    minHeight: 40,
    maxWidth: 40,
    maxHeight: 40,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fieldFill = scheme.surfaceContainerHighest;
    final muted = scheme.onSurfaceVariant;
    final textColor = scheme.onSurface;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      cursorColor: scheme.primary,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: fieldFill,
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: muted,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        prefixIcon: Icon(Icons.search, size: _iconSize, color: muted),
        prefixIconConstraints: _iconConstraints,
        suffixIcon: showClear && onClear != null
            ? IconButton(
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: _iconConstraints,
                icon: Icon(Icons.close, size: _iconSize, color: muted),
              )
            : null,
        suffixIconConstraints: _iconConstraints,
      ),
    );
  }
}
