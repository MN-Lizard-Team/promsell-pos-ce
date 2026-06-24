import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

enum ImageSourceAction { gallery, camera, remove }

/// Shows a bottom sheet to pick an image source (gallery, camera) or remove an existing image.
///
/// [hasImage] controls whether the "Remove image" option is shown.
///
/// Returns the selected action, or `null` if the user dismissed the sheet.
Future<ImageSourceAction?> showImageSourceSheet(
  BuildContext context, {
  required bool hasImage,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<ImageSourceAction>(
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.pickImageGallery),
              onTap: () => Navigator.pop(ctx, ImageSourceAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.pickImageCamera),
              onTap: () => Navigator.pop(ctx, ImageSourceAction.camera),
            ),
            if (hasImage)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.removeImage),
                onTap: () => Navigator.pop(ctx, ImageSourceAction.remove),
              ),
          ],
        ),
      ),
    ),
  );
}
