import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Final onboarding step — compact "all set" summary with a gradient hero
/// header and a summary card listing the configured shop, currency, tax,
/// and PIN status. Mirrors the Command Dashboard hero aesthetic.
class OnboardingDoneSection extends StatelessWidget {
  const OnboardingDoneSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.onFinish,
    required this.onSkip,
    this.shopName,
    this.currencyLabel,
    this.vatLabel,
    this.pinProtected = false,
  });

  final Color cardBg;
  final Color accentBrand;
  final VoidCallback onFinish;
  final VoidCallback onSkip;
  final String? shopName;
  final String? currencyLabel;
  final String? vatLabel;

  /// Whether a store PIN is actually enabled — drives the security summary
  /// row so it never claims protection the user skipped.
  final bool pinProtected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final maxValueWidth = MediaQuery.sizeOf(context).width - 160;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        children: [
          // Gradient hero header (compact).
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [AppColors.darkPrimary, AppColors.primaryDeepDark]
                    : [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    TablerIcons.check,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.onboardingAllSet,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.onboardingReadyToSell,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.onboardingFirstSaleHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Summary card with accent stripe.
          Stack(
            children: [
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(TablerIcons.circleCheck, color: scheme.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              context.l10n.onboardingSetupComplete,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        icon: TablerIcons.buildingStore,
                        label: context.l10n.onboardingSummaryStore,
                        value: shopName,
                        maxValueWidth: maxValueWidth,
                      ),
                      _SummaryRow(
                        icon: TablerIcons.coin,
                        label: context.l10n.onboardingSummaryCurrency,
                        value: currencyLabel,
                        maxValueWidth: maxValueWidth,
                      ),
                      _SummaryRow(
                        icon: TablerIcons.receipt,
                        label: context.l10n.onboardingSummaryTax,
                        value: vatLabel,
                        maxValueWidth: maxValueWidth,
                      ),
                      _SummaryRow(
                        icon: TablerIcons.lock,
                        label: context.l10n.onboardingSecurityProtected,
                        value: pinProtected
                            ? null
                            : context.l10n.onboardingSecurityNotProtected,
                        maxValueWidth: maxValueWidth,
                        isStatus: pinProtected,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.maxValueWidth,
    this.isStatus = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final double maxValueWidth;
  final bool isStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final displayValue = isStatus
        ? '✓'
        : (value == null || value!.trim().isEmpty ? '—' : value!.trim());
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxValueWidth),
            child: Text(
              displayValue,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isStatus ? scheme.primary : scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
