import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/sound_player.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_error_banner.dart';
export 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_format_helper.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_manual_entry.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_permission_denied.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_scan_hint.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_scan_result.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/scan_overlay_painter.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

Future<String?> showProductBarcodeScanner(
  BuildContext context, {
  bool beepOnScan = true,
  List<BarcodeFormat>? formats,
  int autoOpenManualDelay = 0,
  bool continuousScan = true,
  void Function(String barcode)? onScanned,
  Future<Product?> Function(String barcode)? onLookup,
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
          BarcodeFormat.itf14,
          BarcodeFormat.qrCode,
          BarcodeFormat.dataMatrix,
          BarcodeFormat.pdf417,
          BarcodeFormat.aztec,
          BarcodeFormat.codabar,
        ],
    beepOnScan: beepOnScan,
    autoOpenManualDelay: autoOpenManualDelay,
    continuousScan: continuousScan,
    onScanned: onScanned,
    onLookup: onLookup,
  ),
);

class BarcodeScannerDialog extends StatefulWidget {
  const BarcodeScannerDialog({
    super.key,
    required this.formats,
    this.title,
    this.hint,
    this.beepOnScan = true,
    this.autoOpenManualDelay = 0,
    this.continuousScan = true,
    this.onScanned,
    this.onLookup,
  });

  final List<BarcodeFormat> formats;
  final String? title;
  final String? hint;
  final bool beepOnScan;
  final int autoOpenManualDelay;
  final bool continuousScan;
  final void Function(String barcode)? onScanned;
  final Future<Product?> Function(String barcode)? onLookup;

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
  bool _isScanningGallery = false;
  bool _isContinuous = true;
  bool _isLookingUp = false;
  String? _productName;
  double? _productPrice;
  bool? _productFound;
  int _scanCount = 0;
  String? _errorText;
  Timer? _errorClearTimer;
  Timer? _autoOpenTimer;
  Timer? _resetTimer;
  static final _alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  late final AnimationController _laserAnim;
  late final Animation<double> _laserCurve;

  static const _cutoutRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _isContinuous = widget.continuousScan;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
    _resetTimer?.cancel();
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
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
      _setError(context.l10n.barcodeMustBeAlphanumeric);
      return;
    }
    if (_isContinuous && widget.onScanned != null) {
      widget.onScanned!(value);
      _handleScanSuccess(value);
    } else {
      Navigator.of(context).pop(value);
    }
  }

  Future<void> _scanFromGallery() async {
    if (_scanned || _isScanningGallery) return;
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

    setState(() => _isScanningGallery = true);
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

      final cleaned = raw.trim();
      if (!_alphanumeric.hasMatch(cleaned)) {
        _setError(l10n.barcodeMustBeAlphanumeric);
        await _controller.start();
        return;
      }

      setState(() {
        _scanned = true;
        _isScanningGallery = false;
      });
      _scannedValue = cleaned;
      _autoOpenTimer?.cancel();
      if (widget.beepOnScan) {
        HapticFeedback.mediumImpact();
        SoundPlayer.playConfirmation();
      }
      if (_isContinuous && widget.onScanned != null) {
        widget.onScanned!(cleaned);
        _handleScanSuccess(cleaned);
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          Navigator.of(context).pop(cleaned);
        });
      }
    } catch (e) {
      if (!mounted) return;
      _setError(l10n.barcodeNotFoundInImage);
      await _controller.start();
    } finally {
      if (mounted) setState(() => _isScanningGallery = false);
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

    final cleaned = raw.trim();
    if (!_alphanumeric.hasMatch(cleaned)) {
      _setError(context.l10n.barcodeMustBeAlphanumeric);
      return;
    }

    setState(() => _scanned = true);
    _scannedValue = cleaned;
    _autoOpenTimer?.cancel();
    if (widget.beepOnScan) {
      HapticFeedback.mediumImpact();
      SoundPlayer.playConfirmation();
    }

    if (_isContinuous && widget.onScanned != null) {
      widget.onScanned!(cleaned);
      _handleScanSuccess(cleaned);
    } else {
      _controller.stop().then((_) {
        if (!mounted) return;
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          Navigator.of(context).pop(cleaned);
        });
      });
    }
  }

  void _handleScanSuccess(String barcode) {
    _scanCount++;
    _resetTimer?.cancel();

    if (widget.onLookup != null) {
      setState(() => _isLookingUp = true);
      widget.onLookup!(barcode).then((product) {
        if (!mounted) return;
        setState(() {
          _isLookingUp = false;
          _productFound = product != null;
          _productName = product?.name;
          _productPrice = product?.price;
        });
        _scheduleReset();
      });
    } else {
      _scheduleReset();
    }
  }

  void _scheduleReset() {
    _resetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isContinuous) {
        setState(() {
          _scanned = false;
          _scannedValue = null;
          _productName = null;
          _productPrice = null;
          _productFound = null;
          _isLookingUp = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final screenW = MediaQuery.of(context).size.width;
    final cutoutW = (screenW * 0.8).clamp(220.0, 360.0);
    final cutoutH = cutoutW * 0.6;

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
          if (widget.continuousScan)
            IconButton(
              icon: Icon(
                _isContinuous ? Icons.repeat : Icons.repeat_one,
                color: _isContinuous ? theme.colorScheme.primary : null,
              ),
              tooltip: l10n.continuousScan,
              onPressed: () {
                setState(() => _isContinuous = !_isContinuous);
              },
            ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            tooltip: l10n.focusCamera,
            onPressed: () {
              final size = MediaQuery.of(context).size;
              _controller.setFocusPoint(
                Offset(size.width / 2, size.height / 2),
              );
            },
          ),
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
          ? const BarcodePermissionDenied()
          : Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
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
                        cutoutWidth: cutoutW,
                        cutoutHeight: cutoutH,
                        borderRadius: _cutoutRadius,
                        borderColor: _errorText != null
                            ? theme.colorScheme.error
                            : _scanned
                            ? theme.colorScheme.primary
                            : null,
                        laserY: _errorText != null ? null : laserY,
                        laserColor: _errorText != null
                            ? null
                            : _scanned
                            ? theme.colorScheme.primary.withValues(alpha: 0.5)
                            : theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
                if (_isScanningGallery)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            l10n.scanningImage,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Center(
                  child: SizedBox(
                    width: cutoutW,
                    height: cutoutH,
                    child: _scanned
                        ? _isLookingUp
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : BarcodeScanResult(
                                  scannedValue: _scannedValue,
                                  successLabel: _productFound == false
                                      ? l10n.productNotFoundShort
                                      : l10n.scanSuccess,
                                  productName: _productName,
                                  productPrice: _productPrice,
                                  isFound: _productFound,
                                  notFoundLabel: l10n.productNotFoundShort,
                                )
                        : null,
                  ),
                ),
                if (_errorText != null)
                  BarcodeErrorBanner(errorText: _errorText!),
                Positioned(
                  bottom: 48,
                  left: 24,
                  right: 24,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _showManualEntry
                        ? BarcodeManualEntry(
                            controller: _manualCtrl,
                            onSubmit: _submitManual,
                            onCancel: () {
                              setState(() => _showManualEntry = false);
                              _controller.start();
                            },
                          )
                        : BarcodeScanHint(
                            hint: widget.hint,
                            onManualEntry: () {
                              _controller.stop();
                              setState(() => _showManualEntry = true);
                            },
                            scanCount: _isContinuous && _scanCount > 0
                                ? _scanCount
                                : null,
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
