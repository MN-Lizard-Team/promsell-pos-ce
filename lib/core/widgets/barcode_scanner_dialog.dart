import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
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
      debugPrint('Unknown barcode format "$name", defaulting to ean13');
      return BarcodeFormat.ean13;
  }
}

List<BarcodeFormat> barcodeFormatsFromNames(List<String> names) {
  return names.map(_formatFromName).toList();
}

/// Fullscreen barcode scanner dialog.
///
/// [formats] controls which barcode symbologies to detect.
/// [title] overrides the AppBar title.
class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({
    super.key,
    required this.formats,
    this.title,
    this.hint,
    this.beepOnScan = true,
    this.autoOpenManualDelay = 0,
  });

  final List<BarcodeFormat> formats;
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
  String? _scannedValue;
  bool _showManualEntry = false;
  bool _permissionGranted = false;
  bool _permissionChecked = false;
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
          _controller.stop();
          setState(() => _showManualEntry = true);
        }
      });
    }
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() {
      _permissionGranted = status.isGranted;
      _permissionChecked = true;
    });
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
    Navigator.of(context).pop(value);
  }

  Future<void> _scanFromGallery() async {
    if (_scanned) return;
    final l10n = context.l10n;

    if (Platform.isAndroid || Platform.isIOS) {
      final photos = await Permission.photos.request();
      if (!photos.isGranted && !photos.isLimited) {
        _setError(l10n.storagePermissionDenied);
        return;
      }
    }

    await _controller.stop();
    if (!mounted) return;

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      if (mounted) await _controller.start();
      return;
    }

    try {
      final capture = await _controller.analyzeImage(xFile.path);
      if (!mounted) return;

      if (capture == null || capture.barcodes.isEmpty) {
        _setError(l10n.barcodeNotFoundInImage);
        await _controller.start();
        return;
      }

      final raw = capture.barcodes
          .firstWhere(
            (b) => b.rawValue != null && b.rawValue!.isNotEmpty,
            orElse: () => capture.barcodes.first,
          )
          .rawValue;

      if (raw == null || raw.isEmpty) {
        _setError(l10n.barcodeNotFoundInImage);
        await _controller.start();
        return;
      }

      setState(() => _scanned = true);
      _scannedValue = raw;
      _autoOpenTimer?.cancel();
      if (widget.beepOnScan) HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.of(context).pop(raw);
      });
    } catch (e) {
      if (!mounted) return;
      _setError(l10n.barcodeNotFoundInImage);
      await _controller.start();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes
        .firstWhere(
          (b) => b.rawValue != null && b.rawValue!.isNotEmpty,
          orElse: () => barcodes.first,
        )
        .rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _scanned = true);
    _scannedValue = raw;
    _autoOpenTimer?.cancel();
    if (widget.beepOnScan) HapticFeedback.mediumImpact();
    _controller.stop().then((_) {
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.of(context).pop(raw);
      });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            tooltip: l10n.scanFromGallery,
            onPressed: _scanFromGallery,
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.torchState == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
                tooltip: isOn ? l10n.torchOff : l10n.torchOn,
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: !_permissionChecked
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : !_permissionGranted
          ? _buildPermissionDenied(context, l10n, theme)
          : Stack(
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
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _scannedValue ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(blurRadius: 6, color: Colors.black),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.scanSuccess,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 13,
                                  shadows: const [
                                    Shadow(blurRadius: 6, color: Colors.black),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                if (_errorText != null)
                  Positioned(
                    bottom: 200,
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
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
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
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _submitManual(),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: l10n.enterBarcodeManually,
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
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
                                        onPressed: () {
                                          setState(
                                            () => _showManualEntry = false,
                                          );
                                          _controller.start();
                                        },
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
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.hint ?? l10n.barcodeScannerHint,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 1.0),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  shadows: const [
                                    Shadow(blurRadius: 6, color: Colors.black),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: () {
                                  _controller.stop();
                                  setState(() => _showManualEntry = true);
                                },
                                icon: const Icon(
                                  Icons.keyboard,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  l10n.enterManually,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _scanFromGallery,
                                icon: const Icon(
                                  Icons.photo_library,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  l10n.scanFromGallery,
                                  style: const TextStyle(color: Colors.white),
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

  Widget _buildPermissionDenied(
    BuildContext context,
    dynamic l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              l10n.cameraPermissionDenied,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.settings),
              label: Text(l10n.openSettings),
              onPressed: () async {
                await openAppSettings();
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
