import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/barcode_live_strip.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_form/unit_picker_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/shared/product_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class BarcodeField extends StatelessWidget {
  const BarcodeField({
    super.key,
    required this.barcodeCtrl,
    required this.barcodeFocusNode,
    required this.isGeneratingBarcode,
    required this.onGenerateBarcode,
  });

  final TextEditingController barcodeCtrl;
  final FocusNode barcodeFocusNode;
  final bool isGeneratingBarcode;
  final VoidCallback onGenerateBarcode;

  Future<bool> _confirmReplace(BuildContext context, String current) async {
    final l10n = context.l10n;
    return showConfirmationDialog(
      context,
      title: l10n.barcodeReplaceTitle,
      message: l10n.barcodeReplaceMessage(current),
      confirmLabel: l10n.confirm,
      cancelLabel: l10n.cancel,
    );
  }

  Future<void> _onScan(BuildContext context) async {
    final settings = context.read<SettingsCubit>().state.settings;
    final current = barcodeCtrl.text.trim();

    // Single-shot: dialog pops the code (onScanned is only used in continuous).
    final scanned = await showProductBarcodeScanner(
      context,
      beepOnScan: settings.barcodeBeepOnScan,
      formats: barcodeFormatsFromNames(settings.barcodeEnabledFormats),
      autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
      continuousScan: false,
    );
    if (scanned == null || !context.mounted) return;

    final next = scanned.trim().toUpperCase();
    if (next.isEmpty) return;
    if (current.isNotEmpty && current.toUpperCase() != next) {
      final ok = await _confirmReplace(context, current);
      if (!ok || !context.mounted) return;
    }
    barcodeCtrl.text = next;
    barcodeFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProductTextField(
          key: const ValueKey('product-form-barcode'),
          controller: barcodeCtrl,
          focusNode: barcodeFocusNode,
          labelText: l10n.barcodeLabel,
          helperText: l10n.barcodeHelper,
          icon: Icons.qr_code_scanner,
          showIcon: false,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
              return l10n.invalidBarcode;
            }
            return null;
          },
          suffix: IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: l10n.scanBarcode,
            visualDensity: VisualDensity.compact,
            onPressed: () => _onScan(context),
          ),
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: barcodeCtrl,
          builder: (context, _) {
            final value = barcodeCtrl.text.trim();
            if (value.isEmpty) {
              return Text(
                l10n.barcodePreviewEmpty,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              );
            }
            return BarcodeLiveStrip(barcode: value);
          },
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: isGeneratingBarcode ? null : onGenerateBarcode,
            icon: isGeneratingBarcode
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high_outlined, size: 18),
            label: Text(l10n.generateBarcode),
          ),
        ),
      ],
    );
  }
}

class UnitField extends StatelessWidget {
  const UnitField({super.key, required this.controller});

  final TextEditingController controller;

  Future<void> _pick(BuildContext context) async {
    final result = await showUnitPicker(context, current: controller.text);
    if (result != null) {
      controller.text = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final display = controller.text.trim();
        return Semantics(
          button: true,
          label: l10n.productUnitLabel,
          value: display.isEmpty ? l10n.productUnitOther : display,
          child: InkWell(
            key: const ValueKey('product-form-unit'),
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.productUnitLabel,
                suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
              ),
              child: Text(
                display.isEmpty ? l10n.productUnitOther : display,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: display.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sets absolute quantity (create flow / stepper tap) via bottom sheet.
void showStockDialog(
  BuildContext context, {
  required int current,
  required ValueChanged<int> onChanged,
}) {
  final ctrl = TextEditingController(text: '$current');
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    showDragHandle: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) {
      final l10n = ctx.l10n;
      final theme = Theme.of(ctx);
      final cs = theme.colorScheme;
      final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16 + bottomInset,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.quantityLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: ctrl,
                  labelText: l10n.quantityLabel,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  validator: (v) {
                    final qty = int.tryParse(v ?? '');
                    if (qty == null || qty < 0) return l10n.invalidQuantity;
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final qty = int.parse(ctrl.text.trim());
                          Navigator.pop(ctx);
                          onChanged(qty);
                        },
                        child: Text(l10n.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(ctrl.dispose);
}
