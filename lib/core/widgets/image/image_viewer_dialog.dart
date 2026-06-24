import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_page.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_info_sheet.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_page_indicator.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_toolbar_button.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog/image_viewer_utils.dart';

class ImageViewerDialog extends StatefulWidget {
  const ImageViewerDialog({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  final List<ImageProvider> images;
  final int initialIndex;

  static void showSingle(BuildContext context, ImageProvider image) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) => ImageViewerDialog(images: [image]),
    );
  }

  static void showMulti(
    BuildContext context, {
    required List<ImageProvider> images,
    int initialIndex = 0,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (_) =>
          ImageViewerDialog(images: images, initialIndex: initialIndex),
    );
  }

  static ImageProvider providerFromPaths({
    String? imagePath,
    String? imageUrl,
  }) {
    if (imagePath != null &&
        imagePath.isNotEmpty &&
        File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedNetworkImageProvider(imageUrl);
    }
    return const AssetImage('');
  }

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog> {
  late final PageController _pageController;
  late int _currentIndex;
  final Map<int, ZoomController> _zoomControllers = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final zc in _zoomControllers.values) {
      zc.dispose();
    }
    super.dispose();
  }

  ZoomController _getZoomController(int index) {
    return _zoomControllers.putIfAbsent(index, () => ZoomController());
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    for (final entry in _zoomControllers.entries) {
      if (entry.key != index) {
        entry.value.reset?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.images.length > 1;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.images.length,
                itemBuilder: (_, index) {
                  return ImagePage(
                    image: widget.images[index],
                    zoomController: _getZoomController(index),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        ImageViewerToolbarButton(
                          icon: Icons.share,
                          onTap: () => shareImage(widget.images[_currentIndex]),
                        ),
                        const SizedBox(width: 8),
                        ImageViewerToolbarButton(
                          icon: Icons.info_outline,
                          onTap: () => ImageViewerInfoSheet.show(
                            context,
                            widget.images[_currentIndex],
                          ),
                        ),
                        const Spacer(),
                        if (hasMultiple)
                          ImageViewerPageIndicator(
                            count: widget.images.length,
                            currentIndex: _currentIndex,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
