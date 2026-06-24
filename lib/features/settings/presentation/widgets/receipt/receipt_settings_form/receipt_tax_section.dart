import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_shared_widgets.dart';

class ReceiptTaxSection extends StatelessWidget {
  const ReceiptTaxSection({
    super.key,
    required this.settings,
    required this.onUpdate,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final s = settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptSharedWidgets.buildSectionTitle(
          context,
          l10n.settingsSectionTax,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReceiptSharedWidgets.buildChoiceRow(
                context: context,
                icon: Icons.percent_outlined,
                label: l10n.settingsVatMode,
                options: const ['NONE', 'INCLUSIVE', 'EXCLUSIVE'],
                selected: s.vatMode,
                onSelected: (v) => onUpdate(s.copyWith(vatMode: v)),
                labelBuilder: (v) {
                  if (v == 'NONE') return l10n.vatModeNone;
                  if (v == 'INCLUSIVE') return l10n.vatModeInclusive;
                  return l10n.vatModeExclusive;
                },
              ),
              if (s.vatMode != 'NONE') ...[
                const SizedBox(height: 16),
                _buildVatRateTile(context, s),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVatRateTile(BuildContext context, Settings s) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(Icons.percent, color: st.softAccent, size: 22),
      title: Text(
        context.l10n.settingsVatRate,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${s.vatRate.toStringAsFixed(1)}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: st.softTextPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 20),
        ],
      ),
      onTap: () => _showVatRateDialog(context, s),
    );
  }

  void _showVatRateDialog(BuildContext context, Settings s) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: s.vatRate.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsVatRate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [0.0, 7.0, 10.0].map((preset) {
                return ChoiceChip(
                  label: Text('${preset.toStringAsFixed(0)}%'),
                  selected: false,
                  onSelected: (_) {
                    ctrl.text = preset.toStringAsFixed(1);
                  },
                  selectedColor: st.activeAccentContainer,
                  backgroundColor: st.cardBackground,
                  side: BorderSide(color: st.cardBorderColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final n = double.tryParse(ctrl.text.trim());
              if (n != null) {
                onUpdate(s.copyWith(vatRate: n.clamp(0, 30)));
              }
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.save),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}
