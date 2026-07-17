import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';

/// Shared filled-dense text field for POS forms.
///
/// Relies on [ThemeData.inputDecorationTheme] for fill, borders, and padding.
/// Focus ring stays theme primary (teal) — never accent orange.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.showPrefixIcon = false,
    this.suffix,
    this.suffixText,
    this.showClearButton = true,
    this.confirmClear = true,
    this.clearConfirmMinLength = defaultClearConfirmMinLength,
    this.clearButtonKey = const ValueKey('app-text-field-clear'),
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final bool showPrefixIcon;
  final Widget? suffix;
  final String? suffixText;
  final bool showClearButton;

  /// When true (default), the clear (X) may ask for confirmation first.
  final bool confirmClear;

  /// Only prompt when trimmed text length ≥ this (short fields clear immediately).
  final int clearConfirmMinLength;

  /// Default minimum length before clear confirmation (prices/qty skip).
  static const int defaultClearConfirmMinLength = 8;

  final Key clearButtonKey;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final int? maxLines;

  /// Soft/hard limit on typed characters (also applies [LengthLimitingTextInputFormatter]).
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  void _applyClear() {
    controller.clear();
    onChanged?.call('');
  }

  Future<void> _onClearPressed(BuildContext context) async {
    final text = controller.text.trim();
    final needsConfirm = confirmClear && text.length >= clearConfirmMinLength;
    if (!needsConfirm) {
      _applyClear();
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.clearFieldTitle,
      message: l10n.clearFieldConfirm,
      confirmLabel: l10n.clear,
      cancelLabel: l10n.cancel,
    );
    if (!confirmed || !context.mounted) return;
    _applyClear();
  }

  @override
  Widget build(BuildContext context) {
    final lines = maxLines ?? 1;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final showClear =
            showClearButton && enabled && !readOnly && value.text.isNotEmpty;

        Widget? suffixIcon;
        if (showClear || suffix != null) {
          final children = <Widget>[
            if (showClear)
              IconButton(
                key: clearButtonKey,
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                icon: const Icon(Icons.clear, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () => _onClearPressed(context),
              ),
            ?suffix,
          ];
          suffixIcon = children.length == 1
              ? children.first
              : Row(mainAxisSize: MainAxisSize.min, children: children);
        }

        final formatters = <TextInputFormatter>[
          ...?inputFormatters,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ];

        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            helperText: helperText,
            helperMaxLines: 2,
            counterText: maxLength != null ? '' : null,
            prefixIcon: showPrefixIcon && prefixIcon != null
                ? Icon(prefixIcon)
                : null,
            suffixText: suffixText,
            suffixIcon: suffixIcon,
            alignLabelWithHint: lines > 1,
          ),
          keyboardType: keyboardType,
          inputFormatters: formatters.isEmpty ? null : formatters,
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          maxLines: lines,
          maxLength: maxLength,
        );
      },
    );
  }
}
