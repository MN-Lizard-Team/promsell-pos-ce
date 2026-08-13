import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';

/// Skeleton placeholder cards shown while report data is loading.
/// Mimics the real layout (hero card, quick stats, chart, section cards)
/// so the user sees structure instead of a blank screen.
class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key, required this.dateHeader});

  final Widget dateHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reportTheme =
        theme.extension<ReportThemeExtension>() ?? ReportThemeExtension.light;
    final baseColor = scheme.surfaceContainerHighest;

    Widget skeletonBox({double width = double.infinity, double height = 16}) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: SizedBox(width: width, height: height),
      );
    }

    Widget skeletonCard({required double height, required Widget child}) {
      return Card(
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(reportTheme.cardRadius),
        ),
        child: Container(
          width: double.infinity,
          height: height,
          padding: const EdgeInsets.all(18),
          child: child,
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        dateHeader,
        const SizedBox(height: 16),
        // Hero card skeleton
        skeletonCard(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              skeletonBox(width: 80, height: 12),
              const SizedBox(height: 12),
              skeletonBox(width: 180, height: 32),
              const SizedBox(height: 8),
              skeletonBox(width: 120, height: 14),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Quick stats skeleton
        Row(
          children: [
            Expanded(child: skeletonBox(height: 36)),
            const SizedBox(width: 8),
            Expanded(child: skeletonBox(height: 36)),
            const SizedBox(width: 8),
            Expanded(child: skeletonBox(height: 36)),
          ],
        ),
        const SizedBox(height: 16),
        // Chart skeleton
        skeletonCard(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              skeletonBox(width: 100, height: 14),
              const SizedBox(height: 16),
              Expanded(child: skeletonBox(height: 140)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Section card skeleton
        skeletonCard(
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              skeletonBox(width: 120, height: 14),
              const SizedBox(height: 16),
              skeletonBox(height: 16),
              const SizedBox(height: 8),
              skeletonBox(height: 16),
              const SizedBox(height: 8),
              skeletonBox(width: 200, height: 16),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Another section card skeleton
        skeletonCard(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              skeletonBox(width: 140, height: 14),
              const SizedBox(height: 16),
              skeletonBox(height: 16),
              const SizedBox(height: 8),
              skeletonBox(width: 160, height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
