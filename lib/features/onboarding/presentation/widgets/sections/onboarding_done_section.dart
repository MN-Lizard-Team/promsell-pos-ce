import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class OnboardingDoneSection extends StatelessWidget {
  const OnboardingDoneSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.onFinish,
    required this.onSkip,
    this.shopName,
    this.currency,
    this.vatMode,
  });

  final Color cardBg;
  final Color accentBrand;
  final VoidCallback onFinish;
  final VoidCallback onSkip;
  final String? shopName;
  final String? currency;
  final String? vatMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final maxValueWidth = MediaQuery.sizeOf(context).width - 160;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              color: scheme.onPrimaryContainer,
              size: 52,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.onboardingAllSet,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.onboardingReadyToSell,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.onboardingFirstSaleHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.task_alt, color: scheme.primary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          context.l10n.onboardingSetupComplete,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SummaryRow(
                    icon: Icons.store_outlined,
                    label: context.l10n.onboardingSummaryStore,
                    value: shopName,
                    maxValueWidth: maxValueWidth,
                  ),
                  _SummaryRow(
                    icon: Icons.payments_outlined,
                    label: context.l10n.onboardingSummaryCurrency,
                    value: currency,
                    maxValueWidth: maxValueWidth,
                  ),
                  _SummaryRow(
                    icon: Icons.receipt_long_outlined,
                    label: context.l10n.onboardingSummaryTax,
                    value: vatMode,
                    maxValueWidth: maxValueWidth,
                  ),
                  _SummaryRow(
                    icon: Icons.lock_outline,
                    label: context.l10n.onboardingSecurityProtected,
                    value: null,
                    maxValueWidth: maxValueWidth,
                    isStatus: true,
                  ),
                ],
              ),
            ),
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
