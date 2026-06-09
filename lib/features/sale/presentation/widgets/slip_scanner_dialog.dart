import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/slip_verifier.dart';

class SlipScannerDialog extends StatefulWidget {
  const SlipScannerDialog({super.key});

  @override
  State<SlipScannerDialog> createState() => _SlipScannerDialogState();
}

class _SlipScannerDialogState extends State<SlipScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _scanned = false;
  String? _errorText;
  Timer? _debounceTimer;
  Timer? _errorClearTimer;

  @override
  void dispose() {
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
        backgroundColor: Colors.black.withValues(alpha: 0.6),
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
          // Dark overlay outside scan area
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ScanOverlayPainter(cutoutSize: 260, borderRadius: 20),
          ),
          // Scan frame
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
                Icon(
                  Icons.document_scanner,
                  size: 32,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.slipScanHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    shadows: const [Shadow(blurRadius: 6, color: Colors.black)],
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

/// Darkens the screen outside the scan cutout area.
class _ScanOverlayPainter extends CustomPainter {
  _ScanOverlayPainter({required this.cutoutSize, required this.borderRadius});

  final double cutoutSize;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final cutout = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: cutoutSize, height: cutoutSize),
      Radius.circular(borderRadius),
    );
    final path = Path()..addRect(rect);
    path.addRRect(cutout);
    canvas.drawPath(path..fillType = PathFillType.evenOdd, paint);

    // Corner markers
    final markerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const markerLength = 24.0;
    final cornerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: cutoutSize, height: cutoutSize),
      Radius.circular(borderRadius),
    );

    // Top-left
    _drawCorner(canvas, cornerRect, markerPaint, markerLength, true, true);
    // Top-right
    _drawCorner(canvas, cornerRect, markerPaint, markerLength, false, true);
    // Bottom-left
    _drawCorner(canvas, cornerRect, markerPaint, markerLength, true, false);
    // Bottom-right
    _drawCorner(canvas, cornerRect, markerPaint, markerLength, false, false);
  }

  void _drawCorner(
    Canvas canvas,
    RRect rect,
    Paint paint,
    double length,
    bool left,
    bool top,
  ) {
    final x = left ? rect.left : rect.right;
    final y = top ? rect.top : rect.bottom;
    final dx = left ? length : -length;
    final dy = top ? length : -length;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) => false;
}
