import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/ean13_generator.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
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
                  _buildPrefixTile(context, s, cubit),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.barcodeFormats,
                children: [_buildFormatsTile(context, s, cubit, st)],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.barcodeAutoOpenManual,
                children: [_buildAutoOpenTile(context, s, cubit, st)],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.batchGenerateBarcodes,
                children: [_buildBatchGenerateTile(context, s, st)],
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

  Widget _buildFormatsTile(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final allFormats = BarcodeConfig.defaultAllFormats;
    final selected = s.barcodeEnabledFormats;

    String labelFor(String name) {
      switch (name) {
        case 'ean13':
          return l10n.barcodeFormatEan13;
        case 'ean8':
          return l10n.barcodeFormatEan8;
        case 'upcA':
          return l10n.barcodeFormatUpcA;
        case 'upcE':
          return l10n.barcodeFormatUpcE;
        case 'code128':
          return l10n.barcodeFormatCode128;
        case 'code39':
          return l10n.barcodeFormatCode39;
        case 'itf':
          return l10n.barcodeFormatItf;
        case 'qrCode':
          return l10n.barcodeFormatQrCode;
        case 'dataMatrix':
          return l10n.barcodeFormatDataMatrix;
        case 'pdf417':
          return l10n.barcodeFormatPdf417;
        case 'aztec':
          return l10n.barcodeFormatAztec;
        case 'codabar':
          return l10n.barcodeFormatCodabar;
        default:
          return name;
      }
    }

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.filter_list_outlined, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.barcodeFormats,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${selected.length}/${allFormats.length}',
        style: TextStyle(fontSize: 13, color: st.softTextSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: () =>
          _showFormatsDialog(context, s, cubit, allFormats, selected, labelFor),
    );
  }

  void _showFormatsDialog(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
    List<String> allFormats,
    List<String> selected,
    String Function(String) labelFor,
  ) {
    final l10n = context.l10n;
    var tempSelected = List<String>.from(selected);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.barcodeFormats),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => tempSelected = List.from(allFormats));
                        },
                        child: Text(l10n.selectAll),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => tempSelected = []);
                        },
                        child: Text(l10n.deselectAll),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: allFormats.map((name) {
                      final isSelected = tempSelected.contains(name);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(labelFor(name)),
                        dense: true,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              tempSelected.add(name);
                            } else {
                              tempSelected.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: tempSelected.isEmpty
                  ? null
                  : () {
                      cubit.updateField(
                        (s) => s.copyWith(barcodeEnabledFormats: tempSelected),
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

  Widget _buildAutoOpenTile(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final delay = s.barcodeAutoOpenManualDelay;
    final delayOptions = [0, 5, 10, 15, 20, 30];
    String delayLabel(int v) =>
        v == 0 ? l10n.disabled : '$v${l10n.secondsSuffix}';

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.timer_outlined, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.barcodeAutoOpenManual,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        delay == 0 ? l10n.disabled : '$delay${l10n.secondsSuffix}',
        style: TextStyle(fontSize: 13, color: st.softTextSecondary),
      ),
      trailing: DropdownButton<int>(
        value: delay,
        underline: const SizedBox(),
        items: delayOptions
            .map((v) => DropdownMenuItem(value: v, child: Text(delayLabel(v))))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            cubit.updateField((s) => s.copyWith(barcodeAutoOpenManualDelay: v));
          }
        },
      ),
    );
  }

  Widget _buildBatchGenerateTile(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final productBloc = GetIt.I<ProductBloc>();
    final withoutBarcode = productBloc.state.products
        .where((p) => p.barcode == null || p.barcode!.isEmpty)
        .length;

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.barcode_reader, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.batchGenerateBarcodes,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        withoutBarcode > 0
            ? l10n.productsWithoutBarcode(withoutBarcode)
            : l10n.batchGenerateNone,
        style: TextStyle(fontSize: 13, color: st.softTextSecondary),
      ),
      trailing: FilledButton.tonal(
        onPressed: withoutBarcode == 0
            ? null
            : () => _showBatchConfirmDialog(
                context,
                withoutBarcode,
                s.barcodeAutoGeneratePrefix,
              ),
        child: Text(l10n.generateBarcode),
      ),
    );
  }

  void _showBatchConfirmDialog(BuildContext context, int count, String prefix) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.batchGenerateConfirmTitle),
        content: Text(l10n.batchGenerateConfirmBody(count)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              GetIt.I<ProductBloc>().add(
                BarcodesBatchGenerated(prefix: prefix),
              );
            },
            child: Text(l10n.generateBarcode),
          ),
        ],
      ),
    );
  }

  Widget _buildPrefixTile(
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
    Settings s,
    SettingsCubit cubit,
  ) {
    final ctrl = TextEditingController(text: s.barcodeAutoGeneratePrefix);
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

class _BarcodePreviewCard extends StatelessWidget {
  const _BarcodePreviewCard({
    required this.scanEnabled,
    required this.prefix,
    required this.vibrateOnScan,
  });

  final bool scanEnabled;
  final String prefix;
  final bool vibrateOnScan;

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
          _buildRow(
            icon: vibrateOnScan
                ? Icons.vibration
                : Icons.do_not_disturb_on_outlined,
            label: l10n.playBeepOnScan,
            value: vibrateOnScan
                ? l10n.settingsStatusActive
                : l10n.settingsStatusNotSet,
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
