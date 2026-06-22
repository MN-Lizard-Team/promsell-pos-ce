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
  List<BarcodeFormat>? formats,
  int autoOpenManualDelay = 0,
}) => showDialog<String>(
  context: context,
  builder: (dialogContext) => BarcodeScannerDialog(
    formats:
        formats ??
        const [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.itf,
          BarcodeFormat.qrCode,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.pdf417,
          BarcodeFormat.aztec,
          BarcodeFormat.codabar,
        ],
    onScan: (value) => Navigator.of(dialogContext).pop(value),
    beepOnScan: beepOnScan,
    autoOpenManualDelay: autoOpenManualDelay,
  ),
);

BarcodeFormat _formatFromName(String name) {
  switch (name) {
    case 'ean13':
      return BarcodeFormat.ean13;
    case 'ean8':
      return BarcodeFormat.ean8;
    case 'upcA':
      return BarcodeFormat.upcA;
    case 'upcE':
      return BarcodeFormat.upcE;
    case 'code128':
      return BarcodeFormat.code128;
    case 'code39':
      return BarcodeFormat.code39;
    case 'itf':
      return BarcodeFormat.itf;
    case 'qrCode':
      return BarcodeFormat.qrCode;
    case 'dataMatrix':
      return BarcodeFormat.dataMatrix;
    case 'pdf417':
      return BarcodeFormat.pdf417;
    case 'aztec':
      return BarcodeFormat.aztec;
    case 'codabar':
      return BarcodeFormat.codabar;
    default:
      return BarcodeFormat.ean13;
  }
}

List<BarcodeFormat> barcodeFormatsFromNames(List<String> names) {
  return names.map(_formatFromName).toList();
}

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
    this.autoOpenManualDelay = 0,
  });

  final List<BarcodeFormat> formats;
  final ValueChanged<String> onScan;
  final String? title;
  final String? hint;
  final bool beepOnScan;
  final int autoOpenManualDelay;

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  final _manualCtrl = TextEditingController();
  bool _scanned = false;
  bool _showManualEntry = false;
  String? _errorText;
  Timer? _errorClearTimer;
  Timer? _autoOpenTimer;
  static final _alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  late final AnimationController _laserAnim;
  late final Animation<double> _laserCurve;

  static const _cutoutWidth = 300.0;
  static const _cutoutHeight = 180.0;
  static const _cutoutRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: widget.formats,
    );
    _laserAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _laserCurve = CurvedAnimation(parent: _laserAnim, curve: Curves.easeInOut);
    if (widget.autoOpenManualDelay > 0) {
      _autoOpenTimer = Timer(Duration(seconds: widget.autoOpenManualDelay), () {
        if (mounted && !_scanned) {
          setState(() => _showManualEntry = true);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.start();
  }

  @override
  void deactivate() {
    _controller.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    _laserAnim.dispose();
    _manualCtrl.dispose();
    _errorClearTimer?.cancel();
    _autoOpenTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _setError(String? text) {
    if (!mounted) return;
    setState(() => _errorText = text);
    _errorClearTimer?.cancel();
    if (text != null) {
      _errorClearTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _errorText = null);
      });
    }
  }

  void _submitManual() {
    final value = _manualCtrl.text.trim();
    if (value.isEmpty) return;
    if (!_alphanumeric.hasMatch(value)) {
      _setError('Barcode must be alphanumeric (letters and numbers only).');
      return;
    }
    widget.onScan(value);
    Navigator.of(context).pop();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _scanned = true);
    _autoOpenTimer?.cancel();
    if (widget.beepOnScan) HapticFeedback.mediumImpact();
    _controller.stop().then((_) {
      if (!mounted) return;
      widget.onScan(raw);
      Navigator.of(context).pop();
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
          AnimatedBuilder(
            animation: _laserCurve,
            builder: (context, child) {
              final laserY = _scanned ? 0.5 : _laserCurve.value;
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: ScanOverlayPainter(
                  cutoutWidth: _cutoutWidth,
                  cutoutHeight: _cutoutHeight,
                  borderRadius: _cutoutRadius,
                  borderColor: _errorText != null
                      ? theme.colorScheme.error
                      : _scanned
                      ? theme.colorScheme.primary
                      : null,
                  laserY: laserY,
                  laserColor: _errorText != null
                      ? theme.colorScheme.error.withValues(alpha: 0.5)
                      : _scanned
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.primary,
                ),
              );
            },
          ),
          Center(
            child: SizedBox(
              width: _cutoutWidth,
              height: _cutoutHeight,
              child: _scanned
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : null,
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
