import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_source_sheet.dart';
import 'package:promsell_pos_ce/features/product/data/services/image_permission_exception.dart';
import 'package:promsell_pos_ce/features/product/data/services/product_image_service.dart';

typedef ImagePickedCallback =
    void Function(String? imagePath, String? thumbnailPath);
typedef ImageRemovedCallback = void Function();
typedef SetStateCallback = void Function(VoidCallback fn);
typedef IsMountedGetter = bool Function();

class ImageSourceHandler {
  ImageSourceHandler({
    required this.setState,
    required this.isMounted,
    required this.onImagePicked,
    required this.onImageRemoved,
    this.tempImagePaths,
  });

  final void Function(VoidCallback fn) setState;
  final bool Function() isMounted;
  final ImagePickedCallback onImagePicked;
  final ImageRemovedCallback onImageRemoved;
  final List<String>? tempImagePaths;

  bool isPickingImage = false;

  Future<void> showSheet(
    BuildContext context, {
    required bool hasImage,
    required String productId,
    String logTag = 'ImageSourceHandler',
  }) async {
    final l10n = context.l10n;
    final action = await showImageSourceSheet(context, hasImage: hasImage);
    if (action == null || !isMounted()) return;

    if (action == ImageSourceAction.remove) {
      if (!isMounted() || !context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.removeImage),
          content: Text(l10n.removeImageConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      if (!isMounted()) return;
      setState(() {
        onImageRemoved();
      });
      return;
    }

    final imageService = GetIt.I<ProductImageService>();

    setState(() => isPickingImage = true);
    try {
      final path = action == ImageSourceAction.gallery
          ? await imageService.pickFromGallery(productId)
          : await imageService.pickFromCamera(productId);
      if (path == null) {
        setState(() => isPickingImage = false);
        return;
      }
      final thumbPath = await imageService.generateThumbnail(path);
      if (!isMounted()) return;
      setState(() {
        onImagePicked(path, thumbPath);
        isPickingImage = false;
      });
      if (tempImagePaths != null) {
        tempImagePaths!.add(path);
        if (thumbPath != null) tempImagePaths!.add(thumbPath);
      }
      if (!isMounted() || !context.mounted) return;
      AppSnackBar.success(context, l10n.imagePicked);
    } on ImagePermissionException catch (e) {
      if (!isMounted() || !context.mounted) return;
      setState(() => isPickingImage = false);
      final msg = e.type == PermissionType.camera
          ? l10n.cameraPermissionDenied
          : l10n.storagePermissionDenied;
      AppSnackBar.error(context, msg);
      AppLogger.error('$logTag permission denied', error: e);
    } catch (e, stack) {
      if (!isMounted() || !context.mounted) return;
      setState(() => isPickingImage = false);
      AppSnackBar.error(context, l10n.imagePickFailed);
      AppLogger.error('$logTag image pick failed', error: e, stack: stack);
    }
  }

  void deleteTempImages() {
    if (tempImagePaths == null) return;
    for (final path in tempImagePaths!) {
      try {
        final file = File(path);
        if (file.existsSync()) file.deleteSync();
      } catch (e) {
        AppLogger.warning('Failed to delete temp image: $path', error: e);
      }
    }
    tempImagePaths!.clear();
  }
}
