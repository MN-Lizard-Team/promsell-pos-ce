import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_switch_tile.dart';

class BarcodeSettingsPage extends StatelessWidget {
  const BarcodeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final accent = context.settingsTheme.softAccent;
        final st = context.settingsTheme;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.barcodeSettings)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _BarcodePreviewCard(
                scanEnabled: s.barcodeScanEnabled,
                prefix: s.barcodeAutoGeneratePrefix,
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.settingsGeneral,
                children: [
                  SettingsSwitchTile(
                    icon: Icons.camera_alt_outlined,
                    title: l10n.enableBarcodeScan,
                    subtitle: l10n.enableBarcodeScanHint,
                    accentColor: accent,
                    value: s.barcodeScanEnabled,
                    onChanged: (v) {
                      cubit.updateField(
                        (s) => s.copyWith(barcodeScanEnabled: v),
                      );
                    },
                  ),
                  SettingsSwitchTile(
                    icon: Icons.volume_up_outlined,
                    title: l10n.playBeepOnScan,
                    subtitle: l10n.playBeepOnScanHint,
                    accentColor: accent,
                    value: s.barcodeBeepOnScan,
                    onChanged: (v) {
                      cubit.updateField(
                        (s) => s.copyWith(barcodeBeepOnScan: v),
                      );
                    },
                  ),
                  _buildPrefixTile(context, s, cubit),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BarcodeHelpSection(st: st),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrefixTile(
    BuildContext context,
    AppSettings s,
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
            s.barcodeAutoGeneratePrefix,
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
      onTap: () => _showPrefixDialog(context, s, cubit),
    );
  }

  void _showPrefixDialog(
    BuildContext context,
    AppSettings s,
    SettingsCubit cubit,
  ) {
    final ctrl = TextEditingController(text: s.barcodeAutoGeneratePrefix);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.barcodePrefix),
        content: SizedBox(
          width: 280,
          child: TextField(
            controller: ctrl,
            maxLength: 10,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: context.l10n.barcodePrefixHint,
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = ctrl.text.trim();
              if (value.isNotEmpty) {
                cubit.updateField(
                  (s) => s.copyWith(barcodeAutoGeneratePrefix: value),
                );
              }
              Navigator.of(ctx).pop();
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }
}

class _BarcodePreviewCard extends StatelessWidget {
  const _BarcodePreviewCard({required this.scanEnabled, required this.prefix});

  final bool scanEnabled;
  final String prefix;

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
              scanEnabled
                  ? Icons.qr_code_scanner_outlined
                  : Icons.qr_code_outlined,
              color: st.softAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.barcodeSettings,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: scanEnabled
                ? Icons.check_circle_outline
                : Icons.block_outlined,
            label: l10n.enableBarcodeScan,
            value: scanEnabled
                ? l10n.settingsStatusActive
                : l10n.settingsStatusNotSet,
            st: st,
          ),
          _buildRow(
            icon: Icons.text_fields_outlined,
            label: l10n.barcodePrefix,
            value: prefix,
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

class _BarcodeHelpSection extends StatelessWidget {
  const _BarcodeHelpSection({required this.st});

  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      leading: Icon(Icons.help_outline, color: st.softAccent),
      title: Text(
        l10n.barcodeHelpTitle,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        _helpItem(
          icon: Icons.info_outline,
          title: l10n.barcodeHelpWhatIsTitle,
          body: l10n.barcodeHelpWhatIsBody,
          st: st,
        ),
        _helpItem(
          icon: Icons.camera_alt_outlined,
          title: l10n.barcodeHelpHowToScanTitle,
          body: l10n.barcodeHelpHowToScanBody,
          st: st,
        ),
        _helpItem(
          icon: Icons.auto_fix_high_outlined,
          title: l10n.barcodeHelpNoBarcodeTitle,
          body: l10n.barcodeHelpNoBarcodeBody,
          st: st,
        ),
      ],
    );
  }

  Widget _helpItem({
    required IconData icon,
    required String title,
    required String body,
    required SettingsThemeExtension st,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: st.softAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: st.softTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    color: st.softTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
