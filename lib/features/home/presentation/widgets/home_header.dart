import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.shopName,
    required this.onMenuTap,
  });
  final String shopName;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final cs = theme.colorScheme;
    final onPrimary = cs.onPrimary;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.viewPaddingOf(context).top + 16,
        left: 20,
        right: 20,
        bottom: 120,
      ),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: onPrimary),
            onPressed: onMenuTap,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.homeGreeting(
                    shopName.isNotEmpty
                        ? shopName
                        : l10n.onboardingShopNameHint,
                  ),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
