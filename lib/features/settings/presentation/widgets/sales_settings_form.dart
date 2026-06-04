import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SalesSettingsForm extends StatelessWidget {
  const SalesSettingsForm({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Preferences'),
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
                icon: Icons.attach_money_outlined,
                label: l10n.settingsCurrency,
                options: const ['฿', '\$', '€', '¥'],
                selected: settings.currency,
                onSelected: (v) => onUpdate(settings.copyWith(currency: v)),
              ),
              const SizedBox(height: 20),
              _buildChoiceRow(
                context: context,
                icon: Icons.calendar_today_outlined,
                label: l10n.settingsDateFormat,
                options: const ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'],
                selected: settings.dateFormat,
                onSelected: (v) => onUpdate(settings.copyWith(dateFormat: v)),
                labelBuilder: (v) {
                  if (v == 'dd/MM/yyyy') return '31/12/2025';
                  if (v == 'MM/dd/yyyy') return '12/31/2025';
                  return '2025-12-31';
                },
              ),
              const SizedBox(height: 20),
              _buildDraftsTile(
                context: context,
                icon: Icons.folder_copy_outlined,
                label: l10n.settingsMaxDrafts,
                value: settings.maxDrafts,
                min: 5,
                max: 100,
                onChanged: (v) => onUpdate(settings.copyWith(maxDrafts: v)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Display'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                context: context,
                icon: Icons.view_compact_outlined,
                title: l10n.settingsCompactCartMode,
                subtitle: context.l10n.settingsCompactModeSubtitle,
                value: settings.cartCompactMode,
                onChanged: (v) =>
                    onUpdate(settings.copyWith(cartCompactMode: v)),
              ),
              Divider(
                height: 1,
                indent: st.dividerIndent,
                endIndent: st.dividerIndent,
                color: st.cardBorderColor.withValues(alpha: 0.5),
              ),
              _buildSwitchTile(
                context: context,
                icon: Icons.density_small,
                title: l10n.settingsUltraCompactMode,
                subtitle: settings.cartCompactMode && settings.ultraCompactMode
                    ? context.l10n.settingsUltraModeOverrides
                    : context.l10n.settingsUltraModeSubtitle,
                value: settings.ultraCompactMode,
                onChanged: (v) {
                  var next = settings.copyWith(ultraCompactMode: v);
                  if (v) next = next.copyWith(cartCompactMode: false);
                  onUpdate(next);
                },
              ),
            ],
          ),
        ),
      ],
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
    String Function(String)? labelBuilder,
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
                labelBuilder?.call(opt) ?? opt,
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

  Widget _buildDraftsTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: st.softAccent, size: 22),
      title: Text(
        label,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString(),
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
      onTap: () => _showDraftsDialog(
        context: context,
        label: label,
        value: value,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }

  void _showDraftsDialog({
    required BuildContext context,
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: value.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '$min–$max',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n != null) {
                onChanged(n.clamp(min, max));
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

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
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
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: st.softTextSecondary,
            fontSize: 14,
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
