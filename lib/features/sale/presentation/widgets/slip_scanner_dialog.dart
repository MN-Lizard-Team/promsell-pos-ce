import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/slip_verifier.dart';
import 'package:promsell_pos_ce/core/widgets/scan_overlay_painter.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

class SlipScannerDialog extends StatefulWidget {
  const SlipScannerDialog({super.key});

  @override
  State<SlipScannerDialog> createState() => _SlipScannerDialogState();
}

class _SlipScannerDialogState extends State<SlipScannerDialog>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _scanned = false;
  String? _errorText;
  Timer? _debounceTimer;
  Timer? _errorClearTimer;

  late final AnimationController _laserAnim;
  late final Animation<double> _laserCurve;

  static const _cutoutWidth = 300.0;
  static const _cutoutHeight = 180.0;
  static const _cutoutRadius = 16.0;

  @override
  void initState() {
    super.initState();
    _laserAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _laserCurve = CurvedAnimation(parent: _laserAnim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _laserAnim.dispose();
    _debounceTimer?.cancel();
    _errorClearTimer?.cancel();
    _controller.dispose();
    super.dispose();
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
      HapticFeedback.mediumImpact();
      await _controller.stop();

      final result = verifySlip(raw);
      if (result.isValid) {
        if (mounted) Navigator.of(context).pop(result);
      } else {
        if (mounted) {
          setState(() {
            _errorText = result.errorMessage ?? context.l10n.promptpayInvalidQr;
            _scanned = false;
          });
          await _controller.start();
          _errorClearTimer?.cancel();
          _errorClearTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) setState(() => _errorText = null);
          });
        }
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
        backgroundColor: AppColors.overlaySurface,
        elevation: 0,
        title: Text(l10n.slipScanTitle),
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
          // Dark overlay with laser line animation
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
          // Scan frame
          Center(
            child: SizedBox(
              width: _cutoutWidth,
              height: _cutoutHeight,
              child: _scanned
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.overlayIcon,
                      ),
                    )
                  : null,
            ),
          ),
          // Error overlay
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
          // Bottom hint
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.document_scanner,
                  size: 32,
                  color: AppColors.overlayTextSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.slipScanHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.overlayIcon,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black)],
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
