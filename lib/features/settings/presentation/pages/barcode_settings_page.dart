import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_auto_open_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_batch_generate_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_formats_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_help_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_prefix_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_switch_tile.dart';

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
              BarcodePreviewCard(
                scanEnabled: s.barcodeScanEnabled,
                prefix: s.barcodeAutoGeneratePrefix,
                vibrateOnScan: s.barcodeBeepOnScan,
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
                  SettingsSwitchTile(
                    icon: Icons.repeat,
                    title: l10n.continuousScan,
                    subtitle: l10n.continuousScanHint,
                    accentColor: accent,
                    value: s.barcodeContinuousScan,
                    onChanged: (v) {
                      cubit.updateField(
                        (s) => s.copyWith(barcodeContinuousScan: v),
                      );
                    },
                  ),
                  BarcodePrefixTile(settings: s, cubit: cubit),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.barcodeFormats,
                children: [
                  BarcodeFormatsTile(settings: s, cubit: cubit, st: st),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.barcodeAutoOpenManual,
                children: [
                  BarcodeAutoOpenTile(settings: s, cubit: cubit, st: st),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.batchGenerateBarcodes,
                children: [BarcodeBatchGenerateTile(settings: s, st: st)],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BarcodeHelpSection(st: st),
              ),
            ],
          ),
        );
      },
    );
  }
}
