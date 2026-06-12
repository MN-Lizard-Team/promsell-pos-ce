import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/scan_overlay_painter.dart';

/// Opens a fullscreen barcode scanner for product barcodes.
///
/// Returns the scanned barcode string, or `null` if the user cancels.
Future<String?> showProductBarcodeScanner(
  BuildContext context, {
  bool beepOnScan = true,
}) => showDialog<String>(
  context: context,
  builder: (dialogContext) => BarcodeScannerDialog(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.itf,
    ],
    onScan: (value) => Navigator.of(dialogContext).pop(value),
    beepOnScan: beepOnScan,
  ),
);

/// Fullscreen barcode scanner dialog.
///
/// [formats] controls which barcode symbologies to detect.
/// [onScan] is called with the raw barcode string on successful scan.
/// [title] overrides the AppBar title.
class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({
    super.key,
    required this.formats,
    required this.onScan,
    this.title,
    this.hint,
    this.beepOnScan = true,
  });

  final List<BarcodeFormat> formats;
  final ValueChanged<String> onScan;
  final String? title;
  final String? hint;
  final bool beepOnScan;

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog> {
  late final MobileScannerController _controller;
  final _manualCtrl = TextEditingController();
  bool _scanned = false;
  bool _showManualEntry = false;
  String? _errorText;
  Timer? _debounceTimer;
  Timer? _errorClearTimer;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: widget.formats,
    );
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    _debounceTimer?.cancel();
    _errorClearTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _submitManual() {
    final value = _manualCtrl.text.trim();
    if (value.isNotEmpty) {
      widget.onScan(value);
      Navigator.of(context).pop();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted || _scanned) return;

      setState(() => _scanned = true);
      if (widget.beepOnScan) HapticFeedback.mediumImpact();
      await _controller.stop();

      if (mounted) {
        widget.onScan(raw);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        title: Text(widget.title ?? l10n.scanBarcode),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.no_photography,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: ScanOverlayPainter(
              cutoutSize: 260,
              borderRadius: 20,
              borderColor: _errorText != null
                  ? theme.colorScheme.error
                  : _scanned
                  ? theme.colorScheme.primary
                  : null,
            ),
          ),
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _errorText != null
                        ? theme.colorScheme.error
                        : _scanned
                        ? theme.colorScheme.primary
                        : Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _scanned
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : null,
              ),
            ),
          ),
          if (_errorText != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight + 24,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorText!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showManualEntry
                  ? Container(
                      key: const ValueKey('manual'),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _manualCtrl,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submitManual(),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: l10n.enterBarcodeManually,
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showManualEntry = false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: Text(l10n.cancel),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: _submitManual,
                                  child: Text(l10n.submit),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Column(
                      key: const ValueKey('scanner'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.document_scanner,
                          size: 32,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.hint ?? l10n.barcodeScannerHint,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(blurRadius: 6, color: Colors.black),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _showManualEntry = true),
                          icon: const Icon(
                            Icons.keyboard,
                            color: Colors.white70,
                          ),
                          label: Text(
                            l10n.enterManually,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
