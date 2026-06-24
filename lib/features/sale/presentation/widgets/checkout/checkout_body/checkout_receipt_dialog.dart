import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/receipt/receipt_preview.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class CheckoutReceiptDialog {
  CheckoutReceiptDialog._();

  static void show(
    BuildContext context, {
    required Settings settings,
    required ReceiptLabels labels,
    required ReceiptPreviewStyle style,
    required List<ReceiptPreviewItem> items,
    required double total,
    required dynamic vatInfo,
    required String paymentMethod,
    required double? amountReceived,
    required double? changeAmount,
    required String? note,
  }) {
    showDialog(
      context: context,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.92),
      builder: (dialogCtx) => GestureDetector(
        onTap: () => Navigator.of(dialogCtx).pop(),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(dialogCtx).size.height * 0.78,
                        maxWidth: 440,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(dialogCtx).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(dialogCtx).colorScheme.shadow,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InteractiveViewer(
                          panEnabled: true,
                          scaleEnabled: true,
                          minScale: 0.8,
                          maxScale: 3.0,
                          boundaryMargin: const EdgeInsets.all(40),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: ReceiptPreview(
                              settings: settings,
                              labels: labels,
                              style: style,
                              items: items,
                              total: total,
                              vatInfo: vatInfo,
                              paymentMethod: paymentMethod,
                              amountReceived: amountReceived,
                              changeAmount: changeAmount,
                              note: note,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: AppColors.overlaySurface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.of(dialogCtx).pop(),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          color: AppColors.overlayIcon,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
