import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Hero banner for onboarding step 0. Uses the same deep-teal gradient as
/// the Settings Command Dashboard hero so the first-run experience feels
/// like a natural extension of the app. Renders the app title, welcome
/// subtitle, and three trust badges (offline, local, encrypted). An optional
/// [onDismiss] callback renders a close button in the top-right corner so the
/// user can collapse the hero and go straight to the shop-info form.
class OnboardingHeroSection extends StatelessWidget {
  const OnboardingHeroSection({
    super.key,
    required this.isDark,
    required this.subtitle,
    this.height = 150,
    this.onDismiss,
  });

  final bool isDark;
  final String subtitle;
  final double height;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = isDark ? AppColors.darkPrimary : AppColors.primary;
    final end = isDark ? AppColors.primaryDeepDark : AppColors.primaryDark;
    const fg = Colors.white;

    return Semantics(
      label: context.l10n.appTitle,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: height),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [start, end],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    TablerIcons.buildingStore,
                    color: fg,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.appTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      height: 1.15,
                    ),
                  ),
                ),
                if (onDismiss != null) _DismissButton(onTap: onDismiss!),
              ],
            ),
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _TrustBadge(
                      icon: TablerIcons.cloudOff,
                      label: context.l10n.onboardingTrustOffline,
                    ),
                    _TrustBadge(
                      icon: TablerIcons.deviceMobile,
                      label: context.l10n.onboardingTrustLocal,
                    ),
                    _TrustBadge(
                      icon: TablerIcons.lock,
                      label: context.l10n.onboardingTrustEncrypted,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.95)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(
            TablerIcons.x,
            size: 22,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}
