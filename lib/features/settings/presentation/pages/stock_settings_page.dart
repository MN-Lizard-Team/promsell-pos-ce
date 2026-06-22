import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_switch_tile.dart';

class StockSettingsPage extends StatelessWidget {
  const StockSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final accent = context.settingsTheme.softAccent;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsStockPolicy)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _StockPreviewCard(
                allowOversell: s.allowOversell,
                lowStockThreshold: s.lowStockThreshold,
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: 'Policy',
                children: [
                  SettingsSwitchTile(
                    icon: Icons.shopping_cart_outlined,
                    title: l10n.allowOversell,
                    subtitle: l10n.allowOversellHint,
                    accentColor: accent,
                    value: s.allowOversell,
                    onChanged: (v) {
                      cubit.updateField((s) => s.copyWith(allowOversell: v));
                    },
                  ),
                  _buildThresholdTile(context, s, cubit),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThresholdTile(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
  ) {
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
        child: Icon(
          Icons.warning_amber_outlined,
          color: st.softAccent,
          size: 24,
        ),
      ),
      title: Text(
        l10n.lowStockThreshold,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${s.lowStockThreshold}',
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
      onTap: () => _showThresholdDialog(context, s, cubit),
    );
  }

  void _showThresholdDialog(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
  ) {
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: s.lowStockThreshold.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.lowStockThreshold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [3, 5, 10, 20].map((preset) {
                return ChoiceChip(
                  label: Text('$preset'),
                  selected: false,
                  onSelected: (_) {
                    ctrl.text = '$preset';
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
              final n = int.tryParse(ctrl.text.trim());
              if (n != null) {
                cubit.updateField(
                  (s) => s.copyWith(lowStockThreshold: n.clamp(1, 100)),
                );
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
}

class _StockPreviewCard extends StatelessWidget {
  const _StockPreviewCard({
    required this.allowOversell,
    required this.lowStockThreshold,
  });

  final bool allowOversell;
  final int lowStockThreshold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: st.iconContainerBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              allowOversell
                  ? Icons.shopping_cart_checkout_outlined
                  : Icons.inventory_2_outlined,
              color: st.softAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.settingsStockPolicy} Preview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: Icons.shopping_cart_outlined,
            label: l10n.allowOversell,
            value: allowOversell ? l10n.settingsOversellAllowed : 'Blocked',
            st: st,
          ),
          _buildRow(
            icon: Icons.warning_amber_outlined,
            label: l10n.lowStockThreshold,
            value: '$lowStockThreshold items',
            st: st,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required SettingsThemeExtension st,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: st.softAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: st.softTextSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: st.softTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
