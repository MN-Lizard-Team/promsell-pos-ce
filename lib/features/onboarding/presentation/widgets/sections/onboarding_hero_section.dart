import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';

class OnboardingHeroSection extends StatelessWidget {
  const OnboardingHeroSection({
    super.key,
    required this.isDark,
    required this.subtitle,
    this.height = 136,
  });

  final bool isDark;
  final String subtitle;
  final double height;

  String get _imageAsset => isDark
      ? 'assets/images/onboarding/onboarding_dark_preview.png'
      : 'assets/images/onboarding/onboarding_white_preview.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scrimColor = isDark ? AppColors.primaryDark : AppColors.primary;
    return Semantics(
      label: context.l10n.appTitle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            ExcludeSemantics(
              child: Image.asset(
                _imageAsset,
                fit: BoxFit.cover,
                width: double.infinity,
                height: height,
                errorBuilder: (_, _, _) => Container(
                  width: double.infinity,
                  height: height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scrimColor.withValues(alpha: 0.0),
                      scrimColor.withValues(alpha: 0.82),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.appTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      _TrustItem(
                        icon: Icons.cloud_off_outlined,
                        label: context.l10n.onboardingTrustOffline,
                      ),
                      _TrustItem(
                        icon: Icons.phone_android_outlined,
                        label: context.l10n.onboardingTrustLocal,
                      ),
                      _TrustItem(
                        icon: Icons.lock_outline,
                        label: context.l10n.onboardingTrustEncrypted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}
