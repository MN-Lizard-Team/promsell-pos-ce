import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 80, this.borderRadius = 16});

  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkSkeletonBase
        : AppColors.elevatedSurface;
    final highlightColor = isDark
        ? AppColors.darkSkeletonHighlight
        : AppColors.background;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _ShimmerEffect(
          baseColor: baseColor,
          highlightColor: highlightColor,
        ),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) => SkeletonCard(height: itemHeight),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  const _ShimmerEffect({required this.baseColor, required this.highlightColor});

  final Color baseColor;
  final Color highlightColor;

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [0.0, _controller.value, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Container(
            color: widget.baseColor,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}
