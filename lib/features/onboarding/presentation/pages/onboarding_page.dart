import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/id_generator.dart';
import 'package:promsell_pos_ce/features/settings/domain/repositories/settings_repository.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/main.dart';

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
    _vatRateController.dispose();
    _promptPayController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final repo = sl<SettingsRepository>();
    final current = await repo.load();

    final devicePrefix = _generateDevicePrefix();

    final updated = current.copyWith(
      shopName: _shopNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      locale: Locale(_locale),
      currency: _currency,
      dateFormat: _dateFormat,
      vatMode: _vatMode,
      vatRate: double.tryParse(_vatRateController.text) ?? 7.0,
      promptpayId: _promptPayController.text.trim(),
      onboardingCompleted: true,
      deviceId: IdGenerator.newId(),
      devicePrefix: devicePrefix,
    );

    await repo.save(updated);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const PromsellApp()));
    }
  }

  String _generateDevicePrefix() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return String.fromCharCodes(
      List.generate(3, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  Future<void> _skip() async {
    final repo = sl<SettingsRepository>();
    final current = await repo.load();
    final devicePrefix = _generateDevicePrefix();

    final updated = current.copyWith(
      locale: Locale(_locale),
      currency: _currency,
      dateFormat: _dateFormat,
      vatMode: 'NONE',
      vatRate: 7.0,
      onboardingCompleted: true,
      deviceId: IdGenerator.newId(),
      devicePrefix: devicePrefix,
    );

    await repo.save(updated);

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const PromsellApp()));
    }
  }

  void _showOnboardingSettingsSheet(
    BuildContext ctx,
    AppSettings s,
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
                _SheetOption(
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
                _SheetOption(
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
                _SheetOption(
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
                _SheetOption(
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
                _SheetOption(
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
                        _HeroSection(
                          isDark: isDark,
                          title: ctx.l10n.onboardingWelcomeTitle,
                          subtitle: ctx.l10n.onboardingWelcomeSubtitle,
                          accentColor: accentGreen,
                        ),
                        const SizedBox(height: 24),
                        // Section 2: Shop Profile
                        _OnboardingSection(
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
                                controller: TextEditingController(
                                  text: _currency,
                                ),
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
                        _OnboardingSection(
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
                                  _GreenChoiceChip(
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
                                  _GreenChoiceChip(
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
                                  _GreenChoiceChip(
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
                                  _GreenChoiceChip(
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
                                  _GreenChoiceChip(
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
                        _OnboardingSection(
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
                                  _GreenChoiceChip(
                                    label: Text(ctx.l10n.onboardingNone),
                                    selected: _vatMode == 'NONE',
                                    onSelected: (_) =>
                                        setState(() => _vatMode = 'NONE'),
                                  ),
                                  _GreenChoiceChip(
                                    label: Text(ctx.l10n.onboardingInclusive),
                                    selected: _vatMode == 'INCLUSIVE',
                                    onSelected: (_) =>
                                        setState(() => _vatMode = 'INCLUSIVE'),
                                  ),
                                  _GreenChoiceChip(
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
                        _OnboardingSection(
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

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final bool isDark;
  final String title;
  final String subtitle;
  final Color accentColor;

  String get _imageAsset => isDark
      ? 'assets/images/onboarding/onboarding_dark_preview.png'
      : 'assets/images/onboarding/onboarding_white_preview.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => _showFullImage(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Hero image
            Image.asset(
              _imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 220,
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Title & subtitle at bottom
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Promsell POS',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            // Zoom hint icon
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullImage(BuildContext context) {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (ctx) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(
                color: Colors.black.withValues(alpha: 0.95),
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.asset(_imageAsset),
                  ),
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 24,
              right: 24,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(ctx).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GreenChoiceChip extends StatelessWidget {
  const _GreenChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      label: label,
      selected: selected,
      onSelected: onSelected,
      selectedColor: primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

class _OnboardingSection extends StatelessWidget {
  const _OnboardingSection({
    required this.cardBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  final Color cardBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 0,
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected
                  ? accentColor
                  : isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? accentColor
                      : isDark
                      ? Colors.white.withValues(alpha: 0.85)
                      : Colors.black.withValues(alpha: 0.85),
                ),
              ),
            ),
            if (selected) Icon(Icons.check, size: 20, color: accentColor),
          ],
        ),
      ),
    );
  }
}
