import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img_lib;
import 'package:path_provider/path_provider.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';

/// Output format for generated barcode images.
enum BarcodeImageFormat { png, jpeg }

/// Generates barcode images from barcode text.
///
/// Images are saved under the app's documents directory so they persist
/// across sessions and can be referenced by [Product.barcodeImagePath].
class BarcodeImageService {
  BarcodeImageService({PathProvider? pathProvider})
    : _pathProvider = pathProvider ?? const _DefaultPathProvider();

  final PathProvider _pathProvider;

  /// Generate a barcode image for [barcode] and save it to a file named after
  /// [productId]. Returns the saved file path or null if generation fails.
  Future<String?> generate({
    required String barcode,
    required String productId,
    BarcodeImageFormat format = BarcodeImageFormat.png,
    double width = 600,
    double height = 200,
    double pixelRatio = 3.0,
  }) async {
    try {
      final barcodeType = _resolveType(barcode);

      final repaintBoundary = RenderRepaintBoundary();
      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());

      final root = RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      );
      pipelineOwner.rootNode = root;

      final element = RenderObjectToWidgetAdapter(
        container: repaintBoundary,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: Colors.white,
            child: BarcodeWidget(
              barcode: barcodeType,
              data: barcode,
              width: width,
              height: height,
              drawText: true,
              color: Colors.black,
            ),
          ),
        ),
      ).attachToRenderTree(buildOwner);

      buildOwner.buildScope(element);
      buildOwner.finalizeTree();

      root.layout(
        BoxConstraints.tight(Size(width, height)),
        parentUsesSize: true,
      );

      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();

      final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      var bytes = byteData.buffer.asUint8List();
      if (format == BarcodeImageFormat.jpeg) {
        final jpeg = await encodeJpeg(bytes);
        if (jpeg == null) return null;
        bytes = jpeg;
      }

      final ext = format == BarcodeImageFormat.jpeg ? 'jpg' : 'png';
      final file = await _pathProvider.fileFor(productId, ext);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageService.generate failed',
        error: e,
        stack: stack,
      );
      return null;
    }
  }

  /// Encode PNG [bytes] as JPEG. Returns null if decoding fails.
  Future<Uint8List?> encodeJpeg(Uint8List bytes, {int quality = 90}) async {
    try {
      final decoded = img_lib.decodePng(bytes);
      if (decoded == null) return null;
      return img_lib.encodeJpg(decoded, quality: quality);
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageService.encodeJpeg failed',
        error: e,
        stack: stack,
      );
      return null;
    }
  }

  /// Delete the saved barcode image(s) for [productId], if any.
  Future<void> delete(String productId) async {
    try {
      for (final ext in const ['png', 'jpg']) {
        final file = await _pathProvider.fileFor(productId, ext);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e, stack) {
      AppLogger.error(
        'BarcodeImageService.delete failed',
        error: e,
        stack: stack,
      );
    }
  }

  static Barcode _resolveType(String barcode) {
    final clean = barcode.replaceAll(RegExp(r'\s'), '');
    if (RegExp(r'^\d{13}$').hasMatch(clean)) return Barcode.ean13();
    if (RegExp(r'^\d{8}$').hasMatch(clean)) return Barcode.ean8();
    if (RegExp(r'^\d{12}$').hasMatch(clean)) return Barcode.upcA();
    return Barcode.code128();
  }
}

abstract class PathProvider {
  const PathProvider();
  Future<File> fileFor(String productId, String extension);
}

class _DefaultPathProvider implements PathProvider {
  const _DefaultPathProvider();

  @override
  Future<File> fileFor(String productId, String extension) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/barcodes/$productId.$extension');
  }
}
