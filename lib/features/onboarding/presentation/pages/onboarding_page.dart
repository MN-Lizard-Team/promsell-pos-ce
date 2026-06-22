import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/green_choice_chip.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/onboarding_hero_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/onboarding_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/onboarding_sheet_option.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // Shop Info
  final _shopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // Locale & Currency
  final String _locale = 'th';
  String _currency = '฿';
  final _currencyCtrl = TextEditingController(text: '฿');
  String _dateFormat = 'dd/MM/yyyy';

  // Step 4: Tax
  String _vatMode = 'NONE';
  final _vatRateController = TextEditingController(text: '7');

  // Step 5: PromptPay
  final _promptPayController = TextEditingController();

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _currencyCtrl.dispose();
    _vatRateController.dispose();
    _promptPayController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final cubit = context.read<SettingsCubit>();
    final current = cubit.state.settings;
    final devicePrefix = _generateDevicePrefix();

    cubit.updateField(
      (_) => current.copyWith(
        shopName: _shopNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        locale: Locale(_locale),
        currency: _currency,
        dateFormat: _dateFormat,
        vatMode: _vatMode,
        vatRate: double.tryParse(_vatRateController.text) ?? 7.0,
        promptpayId:
            Validators.promptpayId(_promptPayController.text.trim()) ?? '',
        onboardingCompleted: true,
        deviceId: IdGenerator.newId(),
        devicePrefix: devicePrefix,
      ),
    );
  }

  String _generateDevicePrefix() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return String.fromCharCodes(
      List.generate(3, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  Future<void> _skip() async {
    final cubit = context.read<SettingsCubit>();
    final current = cubit.state.settings;
    final devicePrefix = _generateDevicePrefix();

    cubit.updateField(
      (_) => current.copyWith(
        locale: Locale(_locale),
        currency: _currency,
        dateFormat: _dateFormat,
        vatMode: 'NONE',
        vatRate: 7.0,
        onboardingCompleted: true,
        deviceId: IdGenerator.newId(),
        devicePrefix: devicePrefix,
      ),
    );
  }

  void _showOnboardingSettingsSheet(
    BuildContext ctx,
    Settings s,
    Color accent,
  ) {
    final cubit = ctx.read<SettingsCubit>();
    final theme = Theme.of(ctx);
    final l10n = ctx.l10n;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: ctx,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.onboardingLanguage,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                OnboardingSheetOption(
                  icon: Icons.language,
                  label: l10n.onboardingThai,
                  selected: s.locale.languageCode == 'th',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => s.copyWith(locale: const Locale('th')),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: Icons.language,
                  label: l10n.onboardingEnglish,
                  selected: s.locale.languageCode == 'en',
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => s.copyWith(locale: const Locale('en')),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                const SizedBox(height: 16),
                Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsTheme,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                OnboardingSheetOption(
                  icon: Icons.wb_sunny,
                  label: l10n.settingsThemeLight,
                  selected: s.themeMode == ThemeMode.light,
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => s.copyWith(themeMode: ThemeMode.light),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: Icons.nights_stay,
                  label: l10n.settingsThemeDark,
                  selected: s.themeMode == ThemeMode.dark,
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => s.copyWith(themeMode: ThemeMode.dark),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                OnboardingSheetOption(
                  icon: Icons.brightness_auto,
                  label: l10n.settingsThemeSystem,
                  selected: s.themeMode == ThemeMode.system,
                  accentColor: accent,
                  isDark: isDark,
                  onTap: () {
                    cubit.updateField(
                      (_) => s.copyWith(themeMode: ThemeMode.system),
                    );
                    Navigator.pop(sheetCtx);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (ctx, state) {
        final settings = state.settings;
        final progress = _calculateProgress();
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final accentGreen = colorScheme.primary;
        final scaffoldBg = theme.scaffoldBackgroundColor;
        final cardBg = colorScheme.surface;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            backgroundColor: scaffoldBg,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () =>
                    _showOnboardingSettingsSheet(ctx, settings, accentGreen),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Sticky progress bar at top
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: accentGreen.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            accentGreen,
                          ),
                          minHeight: 6,
                        );
                      },
                    ),
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Section
                        OnboardingHeroSection(
                          isDark: isDark,
                          subtitle: ctx.l10n.onboardingWelcomeSubtitle,
                        ),
                        const SizedBox(height: 24),
                        // Section 2: Shop Profile
                        OnboardingSection(
                          cardBg: cardBg,
                          icon: Icons.store,
                          iconColor: accentGreen,
                          title: ctx.l10n.onboardingShopInfoTitle,
                          child: Column(
                            children: [
                              TextField(
                                controller: _shopNameController,
                                decoration: InputDecoration(
                                  labelText: ctx.l10n.onboardingShopNameLabel,
                                  hintText: ctx.l10n.onboardingShopNameHint,
                                  prefixIcon: const Icon(Icons.storefront),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _addressController,
                                decoration: InputDecoration(
                                  labelText: ctx.l10n.onboardingAddressLabel,
                                  hintText: ctx.l10n.onboardingAddressHint,
                                  prefixIcon: const Icon(
                                    Icons.location_on_outlined,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  labelText: ctx.l10n.onboardingPhoneLabel,
                                  hintText: ctx.l10n.onboardingPhoneHint,
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                onChanged: (v) => _currency = v,
                                controller: _currencyCtrl,
                                decoration: InputDecoration(
                                  labelText: ctx.l10n.onboardingCurrency,
                                  hintText: '฿',
                                  prefixIcon: const Icon(Icons.attach_money),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Section 3: Preferences
                        OnboardingSection(
                          cardBg: cardBg,
                          icon: Icons.settings,
                          iconColor: accentGreen,
                          title: ctx.l10n.onboardingLocaleCurrencyTitle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ctx.l10n.onboardingLanguage),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.onboardingThai),
                                    selected:
                                        settings.locale.languageCode == 'th',
                                    onSelected: (_) =>
                                        ctx.read<SettingsCubit>().updateField(
                                          (_) => settings.copyWith(
                                            locale: const Locale('th'),
                                          ),
                                        ),
                                  ),
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.onboardingEnglish),
                                    selected:
                                        settings.locale.languageCode == 'en',
                                    onSelected: (_) =>
                                        ctx.read<SettingsCubit>().updateField(
                                          (_) => settings.copyWith(
                                            locale: const Locale('en'),
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(ctx.l10n.settingsTheme),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.settingsThemeLight),
                                    selected:
                                        settings.themeMode == ThemeMode.light,
                                    onSelected: (_) =>
                                        ctx.read<SettingsCubit>().updateField(
                                          (_) => settings.copyWith(
                                            themeMode: ThemeMode.light,
                                          ),
                                        ),
                                  ),
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.settingsThemeDark),
                                    selected:
                                        settings.themeMode == ThemeMode.dark,
                                    onSelected: (_) =>
                                        ctx.read<SettingsCubit>().updateField(
                                          (_) => settings.copyWith(
                                            themeMode: ThemeMode.dark,
                                          ),
                                        ),
                                  ),
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.settingsThemeSystem),
                                    selected:
                                        settings.themeMode == ThemeMode.system,
                                    onSelected: (_) =>
                                        ctx.read<SettingsCubit>().updateField(
                                          (_) => settings.copyWith(
                                            themeMode: ThemeMode.system,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(ctx.l10n.onboardingDateFormat),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _dateFormat,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'dd/MM/yyyy',
                                    child: Text('dd/MM/yyyy'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'MM/dd/yyyy',
                                    child: Text('MM/dd/yyyy'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'yyyy-MM-dd',
                                    child: Text('yyyy-MM-dd'),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _dateFormat = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Section 4: Business Setup
                        OnboardingSection(
                          cardBg: cardBg,
                          icon: Icons.receipt_long,
                          iconColor: accentGreen,
                          title: ctx.l10n.onboardingTaxSetup,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ctx.l10n.onboardingVatMode),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.onboardingNone),
                                    selected: _vatMode == 'NONE',
                                    onSelected: (_) =>
                                        setState(() => _vatMode = 'NONE'),
                                  ),
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.onboardingInclusive),
                                    selected: _vatMode == 'INCLUSIVE',
                                    onSelected: (_) =>
                                        setState(() => _vatMode = 'INCLUSIVE'),
                                  ),
                                  GreenChoiceChip(
                                    label: Text(ctx.l10n.onboardingExclusive),
                                    selected: _vatMode == 'EXCLUSIVE',
                                    onSelected: (_) =>
                                        setState(() => _vatMode = 'EXCLUSIVE'),
                                  ),
                                ],
                              ),
                              if (_vatMode != 'NONE') ...[
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _vatRateController,
                                  decoration: InputDecoration(
                                    labelText: ctx.l10n.onboardingVatRateLabel,
                                    suffixText: '%',
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Text(
                                ctx.l10n.onboardingPromptPayTitle,
                                style: Theme.of(ctx).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(ctx.l10n.onboardingPromptPaySubtitle),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _promptPayController,
                                decoration: InputDecoration(
                                  labelText:
                                      ctx.l10n.onboardingPromptPayIdLabel,
                                  hintText: ctx.l10n.onboardingPromptPayIdHint,
                                  prefixIcon: const Icon(Icons.qr_code),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Done section
                        OnboardingSection(
                          cardBg: cardBg,
                          icon: Icons.check_circle,
                          iconColor: accentGreen,
                          title: ctx.l10n.onboardingAllSet,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ctx.l10n.onboardingReadyToSell),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _finish,
                                  child: Text(ctx.l10n.onboardingStartSelling),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Skip link
                        Center(
                          child: TextButton(
                            onPressed: _skip,
                            child: Text(ctx.l10n.onboardingSkipSetup),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _calculateProgress() {
    int filled = 0;
    if (_shopNameController.text.trim().isNotEmpty) filled++;
    if (_currency.isNotEmpty) filled++;
    if (_vatMode != 'NONE' || _vatRateController.text.isNotEmpty) filled++;
    return filled / 3;
  }
}
