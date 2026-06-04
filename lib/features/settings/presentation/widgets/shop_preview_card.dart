import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class ShopPreviewCard extends StatelessWidget {
  const ShopPreviewCard({
    required this.shopName,
    required this.address,
    required this.phone,
    super.key,
  });

  final String shopName;
  final String address;
  final String phone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;

    final hasData =
        shopName.isNotEmpty || address.isNotEmpty || phone.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: st.iconContainerBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.storefront_outlined,
              color: st.softAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          if (shopName.isNotEmpty)
            Text(
              shopName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            )
          else
            Text(
              'Your shop name',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: st.mutedText,
              ),
              textAlign: TextAlign.center,
            ),
          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                address,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: st.softTextSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else if (hasData)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'No address set',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: st.mutedText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                phone,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: st.softAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (hasData)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'No phone set',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: st.mutedText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                context.l10n.shopInfoEmptyPreview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: st.mutedText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
