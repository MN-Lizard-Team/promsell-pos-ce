import 'dart:io';

import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_source_sheet.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class ProductImageHandler {
  ProductImageHandler(this._imageService);

  final ProductImageService _imageService;
  final List<String> _tempImagePaths = [];

  String? imagePath;
  String? imageUrl;
  String? imageThumbnailPath;

  bool get hasImage => imagePath != null || imageUrl != null;

  void deleteTempImages() {
    for (final path in _tempImagePaths) {
      try {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      } catch (e) {
        AppLogger.warning('Failed to delete temp image: $path', error: e);
      }
    }
    _tempImagePaths.clear();
  }

  Future<ProductImageResult?> handleImageTap(BuildContext context) async {
    final l10n = context.l10n;
    final action = await showImageSourceSheet(context, hasImage: hasImage);
    if (action == null || !context.mounted) return null;

    if (action == ImageSourceAction.remove) {
      final confirmed = await showConfirmationDialog(
        context,
        title: l10n.removeImage,
        message: l10n.removeImageConfirm,
        confirmLabel: l10n.removeImage,
        cancelLabel: l10n.cancel,
        destructive: true,
        confirmIcon: TablerIcons.photoOff,
      );
      if (!confirmed || !context.mounted) return null;
      deleteTempImages();
      imagePath = null;
      imageUrl = null;
      imageThumbnailPath = null;
      return ProductImageResult.removed;
    }

    try {
      final path = action == ImageSourceAction.gallery
          ? await _imageService.pickFromGallery('new')
          : await _imageService.pickFromCamera('new');
      if (path != null) {
        final thumbPath = await _imageService.generateThumbnail(path);
        deleteTempImages();
        _tempImagePaths.add(path);
        if (thumbPath != null) _tempImagePaths.add(thumbPath);
        imagePath = path;
        imageUrl = null;
        imageThumbnailPath = thumbPath;
        if (context.mounted) AppSnackBar.success(context, l10n.imagePicked);
        return ProductImageResult.picked;
      }
    } catch (e) {
      if (context.mounted) AppSnackBar.error(context, l10n.imagePickFailed);
    }
    return null;
  }
}

enum ProductImageResult { picked, removed }
