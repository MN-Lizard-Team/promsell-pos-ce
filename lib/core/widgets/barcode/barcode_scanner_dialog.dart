import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
export 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_format_helper.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_bottom_panel.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_permission_denied.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog/barcode_scanner_session.dart';
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

  /// When lookup misses (sale), show create CTA; called after dialog closes.
  void Function(String barcode)? onCreateProductFromBarcode,

  /// Currency symbol for found-product price overlay (e.g. ฿).
  String? currency,
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
    onCreateProductFromBarcode: onCreateProductFromBarcode,
    currency: currency,
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
    this.onCreateProductFromBarcode,
    this.currency,
  });

  final List<BarcodeFormat> formats;
  final String? title;
  final String? hint;
  final bool beepOnScan;
  final int autoOpenManualDelay;
  final bool continuousScan;
  final void Function(String barcode)? onScanned;
  final Future<Product?> Function(String barcode)? onLookup;
  final void Function(String barcode)? onCreateProductFromBarcode;
  final String? currency;

  @override
  State<BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<BarcodeScannerDialog>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  final _manualCtrl = TextEditingController();
  late final BarcodeScannerSession _session;
  bool _showManualEntry = false;
  bool _permissionGranted = false;
  bool _permissionChecked = false;
  String? _errorText;
  Timer? _errorClearTimer;

  late final AnimationController _laserAnim;
  late final Animation<double> _laserCurve;

  static const _cutoutRadius = 16.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: widget.formats,
    );
    _session = BarcodeScannerSession(
      controller: _controller,
      manualCtrl: _manualCtrl,
      beepOnScan: widget.beepOnScan,
      continuousScan: widget.continuousScan,
      onScanned: widget.onScanned,
      onLookup: widget.onLookup,
      onCreateProductFromBarcode: widget.onCreateProductFromBarcode,
      isMounted: () => mounted,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
      setError: _setError,
    )..isContinuous = widget.continuousScan;
    _laserAnim = AnimationController(
      vsync: this,
      // Slower laser — less distracting for all-day cashier use.
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _laserCurve = CurvedAnimation(parent: _laserAnim, curve: Curves.easeInOut);
    if (widget.autoOpenManualDelay > 0) {
      _session.autoOpenTimer = Timer(
        Duration(seconds: widget.autoOpenManualDelay),
        () {
          if (mounted && !_session.scanned) {
            _controller.stop();
            setState(() => _showManualEntry = true);
          }
        },
      );
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
    _session.cancelTimers();
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final screenW = MediaQuery.sizeOf(context).width;
    // Slightly wider / shorter frame — better for retail linear barcodes.
    final cutoutW = (screenW * 0.82).clamp(220.0, 380.0);
    final cutoutH = cutoutW * 0.48;
    final session = _session;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.88),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // Force light chrome — theme title/icon colors are often dark on black.
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        actionsIconTheme: const IconThemeData(color: Colors.white, size: 24),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
        title: Text(
          widget.title ?? l10n.scanBarcode,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.continuousScan)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: Material(
                color: session.isContinuous
                    ? AppColors.primary.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => setState(
                    () => session.isContinuous = !session.isContinuous,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          session.isContinuous
                              ? Icons.repeat
                              : Icons.looks_one_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          session.isContinuous
                              ? l10n.scanModeContinuous
                              : l10n.scanModeSingle,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, _) {
              if (state.torchState == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: isOn ? const Color(0xFFFDE68A) : Colors.white,
                ),
                tooltip: isOn ? l10n.torchOff : l10n.torchOn,
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              if (value == 'focus') session.focusCenter(context);
              if (value == 'gallery') session.scanFromGallery(context);
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'focus',
                child: Text(
                  l10n.focusCamera,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'gallery',
                child: Text(
                  l10n.scanFromGallery,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
                  onDetect: (capture) => session.onDetect(context, capture),
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
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Cutout only — no result text inside the aiming frame.
                AnimatedBuilder(
                  animation: _laserCurve,
                  builder: (context, child) {
                    final showLaser =
                        !session.scanned && _errorText == null;
                    final laserY = showLaser ? _laserCurve.value : null;
                    return CustomPaint(
                      size: MediaQuery.sizeOf(context),
                      painter: ScanOverlayPainter(
                        cutoutWidth: cutoutW,
                        cutoutHeight: cutoutH,
                        borderRadius: _cutoutRadius,
                        borderColor: _errorText != null
                            ? theme.colorScheme.error
                            : session.scanned
                            ? AppColors.primaryLight
                            : Colors.white.withValues(alpha: 0.85),
                        laserY: laserY,
                        laserColor: showLaser
                            ? AppColors.primaryLight.withValues(alpha: 0.75)
                            : null,
                      ),
                    );
                  },
                ),
                if (session.isScanningGallery)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // All status / actions live in the bottom panel.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BarcodeBottomPanel(
                    showManualEntry: _showManualEntry,
                    manualController: _manualCtrl,
                    onManualSubmit: () => session.submitManual(context),
                    onManualCancel: () {
                      setState(() => _showManualEntry = false);
                      _controller.start();
                    },
                    onOpenManual: () {
                      _controller.stop();
                      setState(() => _showManualEntry = true);
                    },
                    isLookingUp: session.isLookingUp,
                    isScanned: session.scanned,
                    scannedValue: session.scannedValue,
                    productName: session.productName,
                    productPrice: session.productPrice,
                    currency: widget.currency,
                    productFound: session.productFound,
                    errorText: _errorText,
                    scanCount: session.isContinuous && session.scanCount > 0
                        ? session.scanCount
                        : null,
                    hint: widget.hint,
                    onCreateProduct:
                        session.productFound == false &&
                            widget.onCreateProductFromBarcode != null
                        ? () => session.onCreateFromNotFound(context)
                        : null,
                  ),
                ),
              ],
            ),
    );
  }
}
