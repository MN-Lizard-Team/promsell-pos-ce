import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/sound_player.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

/// Camera / gallery / continuous-scan session logic for [BarcodeScannerDialog].
///
/// UI state stays on the dialog State; this object owns detect/gallery/reset
/// rules so the dialog shell can stay presentation-focused.
class BarcodeScannerSession {
  BarcodeScannerSession({
    required this.controller,
    required this.manualCtrl,
    required this.beepOnScan,
    required this.continuousScan,
    required this.onScanned,
    required this.onLookup,
    required this.onCreateProductFromBarcode,
    required bool Function() isMounted,
    required VoidCallback onStateChanged,
    required void Function(String? text) setError,
  })  : _isMounted = isMounted,
        _onStateChanged = onStateChanged,
        _setError = setError;

  final MobileScannerController controller;
  final TextEditingController manualCtrl;
  final bool beepOnScan;
  final bool continuousScan;
  final void Function(String barcode)? onScanned;
  final Future<Product?> Function(String barcode)? onLookup;
  final void Function(String barcode)? onCreateProductFromBarcode;

  final bool Function() _isMounted;
  final VoidCallback _onStateChanged;
  final void Function(String? text) _setError;

  static final alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');

  bool scanned = false;
  String? scannedValue;
  bool isScanningGallery = false;
  bool isContinuous = true;
  bool isLookingUp = false;
  String? productName;
  double? productPrice;
  bool? productFound;
  int scanCount = 0;

  Timer? _resetTimer;
  Timer? autoOpenTimer;

  void cancelTimers() {
    _resetTimer?.cancel();
    autoOpenTimer?.cancel();
  }

  void submitManual(BuildContext context) {
    final value = manualCtrl.text.trim();
    if (value.isEmpty) return;
    if (!alphanumeric.hasMatch(value)) {
      _setError(context.l10n.barcodeMustBeAlphanumeric);
      return;
    }
    if (isContinuous && onScanned != null) {
      onScanned!(value);
      handleScanSuccess(value);
    } else {
      Navigator.of(context).pop(value);
    }
  }

  Future<void> scanFromGallery(BuildContext context) async {
    if (scanned || isScanningGallery) return;
    final l10n = context.l10n;

    if (Platform.isAndroid || Platform.isIOS) {
      final photos = await Permission.photos.request();
      if (!photos.isGranted && !photos.isLimited) {
        _setError(l10n.storagePermissionDenied);
        return;
      }
    }

    await controller.stop();
    if (!_isMounted() || !context.mounted) return;
    final nav = Navigator.of(context);

    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) {
      if (_isMounted()) await controller.start();
      return;
    }

    isScanningGallery = true;
    _onStateChanged();
    try {
      final capture = await controller.analyzeImage(xFile.path);
      if (!_isMounted()) return;

      if (capture == null || capture.barcodes.isEmpty) {
        _setError(l10n.barcodeNotFoundInImage);
        await controller.start();
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
        await controller.start();
        return;
      }

      final cleaned = raw.trim();
      if (!alphanumeric.hasMatch(cleaned)) {
        _setError(l10n.barcodeMustBeAlphanumeric);
        await controller.start();
        return;
      }

      scanned = true;
      isScanningGallery = false;
      scannedValue = cleaned;
      autoOpenTimer?.cancel();
      _onStateChanged();
      if (beepOnScan) {
        HapticFeedback.mediumImpact();
        SoundPlayer.playConfirmation();
      }
      if (isContinuous && onScanned != null) {
        onScanned!(cleaned);
        handleScanSuccess(cleaned);
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!_isMounted()) return;
          nav.pop(cleaned);
        });
      }
    } catch (_) {
      if (!_isMounted()) return;
      _setError(l10n.barcodeNotFoundInImage);
      await controller.start();
    } finally {
      if (_isMounted()) {
        isScanningGallery = false;
        _onStateChanged();
      }
    }
  }

  void onDetect(BuildContext context, BarcodeCapture capture) {
    if (scanned) return;
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
    if (!alphanumeric.hasMatch(cleaned)) {
      _setError(context.l10n.barcodeMustBeAlphanumeric);
      return;
    }

    scanned = true;
    scannedValue = cleaned;
    autoOpenTimer?.cancel();
    _onStateChanged();
    if (beepOnScan) {
      HapticFeedback.mediumImpact();
      SoundPlayer.playConfirmation();
    }

    if (isContinuous && onScanned != null) {
      onScanned!(cleaned);
      handleScanSuccess(cleaned);
    } else {
      final nav = Navigator.of(context);
      controller.stop().then((_) {
        if (!_isMounted()) return;
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!_isMounted()) return;
          nav.pop(cleaned);
        });
      });
    }
  }

  void handleScanSuccess(String barcode) {
    scanCount++;
    _resetTimer?.cancel();

    if (onLookup != null) {
      isLookingUp = true;
      _onStateChanged();
      onLookup!(barcode).then((product) {
        if (!_isMounted()) return;
        isLookingUp = false;
        productFound = product != null;
        productName = product?.name;
        productPrice = product?.price.value;
        _onStateChanged();
        scheduleReset();
      });
    } else {
      scheduleReset();
    }
  }

  void scheduleReset() {
    _resetTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!_isMounted() || !isContinuous) return;
      // Keep not-found CTA visible until next detect or user taps create.
      if (productFound == false && onCreateProductFromBarcode != null) {
        return;
      }
      scanned = false;
      scannedValue = null;
      productName = null;
      productPrice = null;
      productFound = null;
      isLookingUp = false;
      _onStateChanged();
    });
  }

  void onCreateFromNotFound(BuildContext context) {
    final code = (scannedValue ?? '').trim();
    if (code.isEmpty || onCreateProductFromBarcode == null) return;
    _resetTimer?.cancel();
    Navigator.of(context).pop();
    onCreateProductFromBarcode!(code);
  }

  void focusCenter(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    controller.setFocusPoint(Offset(size.width / 2, size.height / 2));
  }
}
