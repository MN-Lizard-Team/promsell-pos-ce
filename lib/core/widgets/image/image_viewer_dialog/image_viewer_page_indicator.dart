import 'package:flutter/material.dart';

class ImageViewerPageIndicator extends StatelessWidget {
  const ImageViewerPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == currentIndex ? 10 : 6,
          height: i == currentIndex ? 10 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == currentIndex
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
