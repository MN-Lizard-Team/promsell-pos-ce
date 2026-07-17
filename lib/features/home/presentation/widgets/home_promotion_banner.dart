import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';

class HomePromotionBanner extends StatefulWidget {
  const HomePromotionBanner({
    super.key,
    required this.promotion,
    required this.onTap,
  });

  final Promotion? promotion;
  final VoidCallback onTap;

  @override
  State<HomePromotionBanner> createState() => _HomePromotionBannerState();
}

class _HomePromotionBannerState extends State<HomePromotionBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(
      begin: 0,
      end: -4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _discountLabel(BuildContext context, Promotion promo) {
    final l10n = context.l10n;
    if (promo.type == PromotionType.percent) {
      return l10n.promotionPercentOff(promo.value.toStringAsFixed(0));
    }
    return l10n.promotionAmountOff(promo.value.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cs = theme.colorScheme;
    final onPrimary = cs.onPrimary;
    final promo = widget.promotion;
    final hasPromo = promo != null;

    final title = hasPromo ? promo.name : l10n.homeCreatePromotion;
    final subtitle = hasPromo
        ? _discountLabel(context, promo)
        : l10n.homeNoActivePromotion;
    final cta = hasPromo ? l10n.promotionsTitle : l10n.homePromotionBannerCta;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.promotionGradientStart,
                  AppColors.promotionGradientEnd,
                ],
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    top: 16,
                    bottom: 16,
                    right: 130,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: onPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: onPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: onPrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cta,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.promotionGradientEnd,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 22,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatAnimation.value),
                          child: child,
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/home/home_promotion_banner.png',
                          height: 90,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
