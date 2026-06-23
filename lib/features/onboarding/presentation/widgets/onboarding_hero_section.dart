import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

class OnboardingHeroSection extends StatelessWidget {
  const OnboardingHeroSection({
    super.key,
    required this.isDark,
    required this.subtitle,
  });

  final bool isDark;
  final String subtitle;

  String get _imageAsset => isDark
      ? 'assets/images/onboarding/onboarding_dark_preview.png'
      : 'assets/images/onboarding/onboarding_white_preview.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.asset(
              _imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 220,
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, AppColors.overlaySurface],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Promsell POS',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.overlayIcon,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.overlayTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.overlaySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: AppColors.overlayIcon,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (ctx) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                color: AppColors.overlayBackground,
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.asset(_imageAsset),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 24,
              right: 24,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: AppColors.overlayIcon,
                  size: 28,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.overlayTextSecondary.withValues(
                    alpha: 0.15,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
