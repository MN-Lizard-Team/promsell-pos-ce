import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class ImageViewerInfoSheet {
  ImageViewerInfoSheet._();

  static void show(BuildContext context, ImageProvider image) {
    String source = 'Unknown';
    String? path;
    int? fileSize;

    if (image is FileImage) {
      source = 'Local file';
      path = image.file.path;
      try {
        fileSize = image.file.lengthSync();
      } catch (_) {}
    } else if (image is CachedNetworkImageProvider) {
      source = 'Network';
      path = image.url;
    }

    showModalBottomSheet(
      context: context,
      enableDrag: true,
      showDragHandle: false,
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Image Info',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(label: 'Source', value: source),
              if (path != null) _InfoRow(label: 'Path', value: path),
              if (fileSize != null)
                _InfoRow(
                  label: 'Size',
                  value: '${(fileSize / 1024).toStringAsFixed(1)} KB',
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
