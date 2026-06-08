import 'package:flutter/material.dart';

class AppTextDialog extends StatefulWidget {
  const AppTextDialog({
    super.key,
    required this.title,
    this.initialValue,
    this.hint,
    this.label,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.submitLabel,
    this.cancelLabel,
    this.icon,
    this.selectAllOnOpen = true,
  });

  final String title;
  final String? initialValue;
  final String? hint;
  final String? label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final String? submitLabel;
  final String? cancelLabel;
  final IconData? icon;
  final bool selectAllOnOpen;

  static Future<String?> show({
    required BuildContext context,
    required String title,
    String? initialValue,
    String? hint,
    String? label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
    String? submitLabel,
    String? cancelLabel,
    IconData? icon,
    bool selectAllOnOpen = true,
  }) => showDialog<String>(
    context: context,
    builder: (_) => AppTextDialog(
      title: title,
      initialValue: initialValue,
      hint: hint,
      label: label,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      submitLabel: submitLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      selectAllOnOpen: selectAllOnOpen,
    ),
  );

  @override
  State<AppTextDialog> createState() => _AppTextDialogState();
}

class _AppTextDialogState extends State<AppTextDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _submitted = true);
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            if (!_submitted) return null;
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            labelText: widget.label,
            prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(widget.submitLabel ?? 'Save'),
        ),
      ],
    );
  }
}
