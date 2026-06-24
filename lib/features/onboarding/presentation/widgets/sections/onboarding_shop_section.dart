import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';

class OnboardingShopSection extends StatelessWidget {
  const OnboardingShopSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.shopNameController,
    required this.addressController,
    required this.phoneController,
    required this.currencyController,
    required this.onCurrencyChanged,
  });

  final Color cardBg;
  final Color accentBrand;
  final TextEditingController shopNameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController currencyController;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingSection(
      cardBg: cardBg,
      icon: Icons.store,
      iconColor: accentBrand,
      title: context.l10n.onboardingShopInfoTitle,
      child: Column(
        children: [
          TextField(
            controller: shopNameController,
            decoration: InputDecoration(
              labelText: context.l10n.onboardingShopNameLabel,
              hintText: context.l10n.onboardingShopNameHint,
              prefixIcon: const Icon(Icons.storefront),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            decoration: InputDecoration(
              labelText: context.l10n.onboardingAddressLabel,
              hintText: context.l10n.onboardingAddressHint,
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: context.l10n.onboardingPhoneLabel,
              hintText: context.l10n.onboardingPhoneHint,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: onCurrencyChanged,
            controller: currencyController,
            decoration: InputDecoration(
              labelText: context.l10n.onboardingCurrency,
              hintText: '฿',
              prefixIcon: const Icon(Icons.attach_money),
            ),
          ),
        ],
      ),
    );
  }
}
