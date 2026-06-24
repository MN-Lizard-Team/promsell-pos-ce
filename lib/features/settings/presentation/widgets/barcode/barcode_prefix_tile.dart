import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
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
    final ctrl = TextEditingController(
      text: settings.barcodeAutoGeneratePrefix,
    );
    final l10n = context.l10n;
    final st = context.settingsTheme;
    String? errorText;
    String? previewBarcode;

    void updatePreview(String value) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty &&
          trimmed.length <= 3 &&
          RegExp(r'^[0-9]+$').hasMatch(trimmed)) {
        try {
          previewBarcode = Ean13Generator.generate(prefix: trimmed);
        } catch (_) {
          previewBarcode = null;
        }
      } else {
        previewBarcode = null;
      }
    }

    updatePreview(ctrl.text);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.barcodePrefix),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrl,
                  maxLength: 3,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: l10n.barcodePrefixHint,
                    errorText: errorText,
                  ),
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      errorText = null;
                      updatePreview(value);
                    });
                  },
                ),
                if (previewBarcode != null) ...[
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
                          previewBarcode!,
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
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final value = ctrl.text.trim();
                if (value.isEmpty ||
                    value.length > 3 ||
                    !RegExp(r'^[0-9]+$').hasMatch(value)) {
                  setState(() {
                    errorText = l10n.barcodePrefixError;
                  });
                  return;
                }
                cubit.updateField(
                  (s) => s.copyWith(barcodeAutoGeneratePrefix: value),
                );
                Navigator.of(ctx).pop();
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
