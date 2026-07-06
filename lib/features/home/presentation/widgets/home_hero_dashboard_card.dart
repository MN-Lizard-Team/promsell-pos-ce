import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/home/presentation/widgets/home_sparkline.dart';
import 'package:shimmer/shimmer.dart';

class HomeHeroDashboardCard extends StatefulWidget {
  const HomeHeroDashboardCard({
    super.key,
    required this.todayRevenue,
    required this.todaySalesCount,
    required this.trendData,
    this.isLoading = false,
    this.onTap,
  });

  final double todayRevenue;
  final int todaySalesCount;
  final List<double> trendData;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  State<HomeHeroDashboardCard> createState() => _HomeHeroDashboardCardState();
}

class _HomeHeroDashboardCardState extends State<HomeHeroDashboardCard> {
  double _displayRevenue = 0;

  @override
  void didUpdateWidget(HomeHeroDashboardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todayRevenue != widget.todayRevenue && !widget.isLoading) {
      _displayRevenue = widget.todayRevenue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cs = theme.colorScheme;

    return Semantics(
      button: widget.onTap != null,
      label:
          '${l10n.homeTodayRevenue} ${CurrencyFormatter.format(widget.todayRevenue)} ${l10n.homeFromBills(widget.todaySalesCount)}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 8,
        shadowColor: cs.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 100),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.homeTodayRevenue,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.isLoading)
                          _buildShimmerBox(cs, 140, 32, 8)
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              AnimatedFlipCounter(
                                value: _displayRevenue.truncateToDouble(),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                fractionDigits: 0,
                                thousandSeparator: ',',
                                prefix: '฿ ',
                                textStyle: theme.textTheme.headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                              Text(
                                '.${(widget.todayRevenue.abs() % 1).toStringAsFixed(2).substring(2)}',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                  color: const Color(0xFF105D67),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        if (widget.isLoading)
                          _buildShimmerBox(cs, 100, 16, 6)
                        else
                          Text(
                            l10n.homeFromBills(widget.todaySalesCount),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ExcludeSemantics(
                      child: HomeSparkline(
                        data: widget.trendData,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerBox(ColorScheme cs, double w, double h, double radius) {
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest,
      highlightColor: cs.surfaceContainerLow,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
