import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/barcode_symbology.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Compact live barcode glyph under the product form barcode field.
class BarcodeLiveStrip extends StatelessWidget {
  const BarcodeLiveStrip({super.key, required this.barcode});

  final String barcode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final value = barcode.trim();
    if (value.isEmpty) return const SizedBox.shrink();

    final type = resolveBarcodeSymbology(value);
    final typeLabel = barcodeSymbologyLabel(value);

    return Container(
      key: const ValueKey('product-form-barcode-live-strip'),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 56,
                  child: ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: BarcodeWidget(
                        barcode: type,
                        data: value.replaceAll(RegExp(r'\s'), ''),
                        drawText: false,
                        errorBuilder: (_, _) => Center(
                          child: Text(
                            l10n.unsupportedFormat,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.error,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Text(
                        typeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('product-form-barcode-copy'),
            tooltip: l10n.copyBarcode,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                AppSnackBar.info(context, l10n.copyBarcode);
              }
            },
            icon: Icon(TablerIcons.copy, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
