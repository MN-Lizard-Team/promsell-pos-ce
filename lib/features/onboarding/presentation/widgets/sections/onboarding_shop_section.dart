import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';

class OnboardingShopSection extends StatelessWidget {
  const OnboardingShopSection({
    super.key,
    required this.cardBg,
    required this.accentBrand,
    required this.shopNameController,
    required this.addressController,
    required this.phoneController,
    required this.taxIdController,
    this.shopNameFocus,
    this.addressFocus,
    this.phoneFocus,
    this.taxIdFocus,
    this.onChanged,
  });

  final Color cardBg;
  final Color accentBrand;
  final TextEditingController shopNameController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController taxIdController;
  final FocusNode? shopNameFocus;
  final FocusNode? addressFocus;
  final FocusNode? phoneFocus;
  final FocusNode? taxIdFocus;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingSection(
      cardBg: cardBg,
      icon: Icons.store,
      iconColor: accentBrand,
      title: context.l10n.onboardingShopInfoTitle,
      subtitle: context.l10n.onboardingShopInfoSubtitle,
      child: Column(
        children: [
          TextField(
            controller: shopNameController,
            focusNode: shopNameFocus,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => addressFocus?.requestFocus(),
            onChanged: (_) => onChanged?.call(),
            decoration: InputDecoration(
              labelText: context.l10n.onboardingShopNameLabel,
              hintText: context.l10n.onboardingShopNameHint,
              prefixIcon: const Icon(Icons.storefront),
              helperText: context.l10n.onboardingRequiredLabel,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: addressController,
            focusNode: addressFocus,
            maxLines: 2,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => phoneFocus?.requestFocus(),
            onChanged: (_) => onChanged?.call(),
            decoration: InputDecoration(
              labelText: context.l10n.onboardingAddressLabel,
              hintText: context.l10n.onboardingAddressHint,
              prefixIcon: const Icon(Icons.location_on_outlined),
              helperText: context.l10n.onboardingOptionalLabel,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            focusNode: phoneFocus,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => taxIdFocus?.requestFocus(),
            onChanged: (_) => onChanged?.call(),
            decoration: InputDecoration(
              labelText: context.l10n.onboardingPhoneLabel,
              hintText: context.l10n.onboardingPhoneHint,
              prefixIcon: const Icon(Icons.phone_outlined),
              helperText: context.l10n.onboardingOptionalLabel,
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: taxIdController,
            focusNode: taxIdFocus,
            textInputAction: TextInputAction.done,
            onChanged: (_) => onChanged?.call(),
            decoration: InputDecoration(
              labelText: context.l10n.settingsTaxId,
              hintText: context.l10n.taxIdHint,
              prefixIcon: const Icon(Icons.badge_outlined),
              helperText: context.l10n.onboardingOptionalLabel,
              counterText: '',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(13),
            ],
            validator: (v) {
              final raw = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
              if (raw.isEmpty) return null;
              if (raw.length != 13) {
                return context.l10n.taxIdInvalid;
              }
              try {
                Validators.thaiTaxId(raw);
              } on ArgumentError {
                return context.l10n.taxIdChecksumInvalid;
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
          const SizedBox(height: 16),
          _ReceiptHeaderPreview(
            shopName: shopNameController.text,
            address: addressController.text,
            phone: phoneController.text,
            taxId: taxIdController.text,
          ),
        ],
      ),
    );
  }
}

class _ReceiptHeaderPreview extends StatelessWidget {
  const _ReceiptHeaderPreview({
    required this.shopName,
    required this.address,
    required this.phone,
    required this.taxId,
  });

  final String shopName;
  final String address;
  final String phone;
  final String taxId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    final secondary = theme.colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.onboardingReceiptPreviewTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              color: secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text(
                  shopName.trim().isEmpty
                      ? context.l10n.onboardingReceiptPreviewEmpty
                      : shopName.trim(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (address.trim().isNotEmpty)
                  Text(
                    address.trim(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondary,
                    ),
                  ),
                if (phone.trim().isNotEmpty)
                  Text(
                    phone.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondary,
                    ),
                  ),
                if (taxId.trim().isNotEmpty)
                  Text(
                    '${context.l10n.receiptTaxId}: ${taxId.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondary,
                    ),
                  ),
                const SizedBox(height: 8),
                Divider(color: theme.colorScheme.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
