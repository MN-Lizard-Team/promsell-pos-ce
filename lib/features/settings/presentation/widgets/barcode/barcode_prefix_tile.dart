import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class BarcodePrefixTile extends StatelessWidget {
  const BarcodePrefixTile({
    super.key,
    required this.settings,
    required this.cubit,
  });

  final Settings settings;
  final SettingsCubit cubit;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.text_fields_outlined, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.barcodePrefix,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        l10n.barcodePrefixHint,
        style: TextStyle(fontSize: 13, color: st.softTextSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            settings.barcodeAutoGeneratePrefix,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: st.softTextPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 24),
        ],
      ),
      onTap: () => _showPrefixDialog(context),
    );
  }

  void _showPrefixDialog(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    showDialog<void>(
      context: context,
      builder: (_) => _BarcodePrefixDialog(
        initialValue: settings.barcodeAutoGeneratePrefix,
        title: l10n.barcodePrefix,
        hint: l10n.barcodePrefixHint,
        errorText: l10n.barcodePrefixError,
        cancelLabel: l10n.cancel,
        saveLabel: l10n.save,
        st: st,
        onSave: (value) {
          cubit.updateField(
            (s) => s.copyWith(barcodeAutoGeneratePrefix: value),
          );
        },
      ),
    );
  }
}

class _BarcodePrefixDialog extends StatefulWidget {
  const _BarcodePrefixDialog({
    required this.initialValue,
    required this.title,
    required this.hint,
    required this.errorText,
    required this.cancelLabel,
    required this.saveLabel,
    required this.st,
    required this.onSave,
  });

  final String initialValue;
  final String title;
  final String hint;
  final String errorText;
  final String cancelLabel;
  final String saveLabel;
  final SettingsThemeExtension st;
  final ValueChanged<String> onSave;

  @override
  State<_BarcodePrefixDialog> createState() => _BarcodePrefixDialogState();
}

class _BarcodePrefixDialogState extends State<_BarcodePrefixDialog> {
  late final TextEditingController _ctrl;
  String? _fieldError;
  String? _previewBarcode;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _updatePreview(_ctrl.text);
  }

  @override
  void dispose() {
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  void _updatePreview(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty &&
        trimmed.length <= 3 &&
        RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
      try {
        _previewBarcode = GetIt.I<Ean13Generator>().generate(prefix: trimmed);
      } catch (_) {
        _previewBarcode = null;
      }
    } else {
      _previewBarcode = null;
    }
  }

  void _pop() {
    unfocusForDialogClose();
    Navigator.of(context).pop();
  }

  void _submit() {
    final value = _ctrl.text.trim();
    if (value.isEmpty ||
        value.length > 3 ||
        !RegExp(r'^[0-9]+$').hasMatch(value)) {
      setState(() => _fieldError = widget.errorText);
      return;
    }
    widget.onSave(value);
    _pop();
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.st;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 280,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ctrl,
              maxLength: 3,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: widget.hint,
                errorText: _fieldError,
              ),
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  _fieldError = null;
                  _updatePreview(value);
                });
              },
              onSubmitted: (_) => _submit(),
            ),
            if (_previewBarcode != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: st.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: st.cardBorderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_2, size: 16, color: st.softAccent),
                    const SizedBox(width: 8),
                    Text(
                      _previewBarcode!,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1.2,
                        color: st.softTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _pop, child: Text(widget.cancelLabel)),
        FilledButton(onPressed: _submit, child: Text(widget.saveLabel)),
      ],
    );
  }
}
