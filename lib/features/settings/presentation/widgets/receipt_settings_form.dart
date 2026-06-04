import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class ReceiptSettingsForm extends StatelessWidget {
  const ReceiptSettingsForm({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final s = settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, l10n.settingsSectionContent),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            children: [
              _buildNoteTile(context, s),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.info_outline,
                title: l10n.settingsShowShopInfo,
                value: s.showShopInfoOnReceipt,
                onChanged: (v) =>
                    onUpdate(s.copyWith(showShopInfoOnReceipt: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, l10n.settingsSectionPreview),
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
              _buildChoiceRow(
                context: context,
                icon: Icons.receipt_long_outlined,
                label: l10n.settingsReceiptPreviewStyle,
                options: const ['thermal', 'card', 'none'],
                selected: s.receiptPreviewStyle,
                onSelected: (v) =>
                    onUpdate(s.copyWith(receiptPreviewStyle: v)),
                labelBuilder: (v) {
                  if (v == 'thermal') return l10n.receiptPreviewStyleThermal;
                  if (v == 'card') return l10n.receiptPreviewStyleCard;
                  return l10n.receiptPreviewStyleNone;
                },
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                context: context,
                icon: Icons.preview_outlined,
                title: l10n.settingsShowPreSalePreview,
                value: s.showPreSalePreview,
                onChanged: (v) =>
                    onUpdate(s.copyWith(showPreSalePreview: v)),
              ),
              const SizedBox(height: 8),
              _buildSwitchTile(
                context: context,
                icon: Icons.receipt_outlined,
                title: l10n.settingsShowPostSalePreview,
                value: s.showPostSalePreview,
                onChanged: (v) =>
                    onUpdate(s.copyWith(showPostSalePreview: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, l10n.settingsSectionTax),
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
              _buildChoiceRow(
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

  Widget _buildNoteTile(BuildContext context, AppSettings s) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final preview = s.receiptNote.isEmpty ? '—' : s.receiptNote;

    return ListTile(
      leading: Icon(
        Icons.receipt_long_outlined,
        color: st.softAccent,
        size: 22,
      ),
      title: Text(
        l10n.settingsReceiptNote,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              preview,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: st.softTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 20),
        ],
      ),
      onTap: () => _showNoteDialog(context, s),
    );
  }

  void _showNoteDialog(BuildContext context, AppSettings s) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: s.receiptNote);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsReceiptNote),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          minLines: 3,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.settingsReceiptNoteHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              onUpdate(s.copyWith(receiptNote: ctrl.text));
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildVatRateTile(BuildContext context, AppSettings s) {
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

  void _showVatRateDialog(BuildContext context, AppSettings s) {
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: s.vatRate.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsVatRate),
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
                  selectedColor: st.softAccentContainer,
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
            child: Text(context.l10n.cancel),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 10, top: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: st.mutedText,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildChoiceRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
    required String Function(String) labelBuilder,
  }) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: st.softAccent, size: 22),
            const SizedBox(width: 10),
            Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = opt == selected;
            return ChoiceChip(
              label: Text(
                labelBuilder(opt),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? st.softTextPrimary : st.softTextSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(opt),
              selectedColor: st.softAccentContainer,
              backgroundColor: st.cardBackground,
              side: BorderSide(
                color: isSelected ? st.softAccent : st.cardBorderColor,
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return MergeSemantics(
      child: ListTile(
        minTileHeight: st.tileMinHeight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: st.iconSize,
          height: st.iconSize,
          decoration: BoxDecoration(
            color: st.iconContainerBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: st.softAccent, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: (v) {
            HapticFeedback.lightImpact();
            onChanged(v);
          },
          activeThumbColor: st.softAccent,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onChanged(!value);
        },
      ),
    );
  }
}
