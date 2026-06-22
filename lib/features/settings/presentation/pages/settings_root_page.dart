import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_category_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_dashboard_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_status_chip.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/general_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/sales_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/receipt_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/discount_policy_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/stock_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/barcode_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/image_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_list_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/db_health_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/promptpay_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (_, curr) => curr.status == SettingsStatus.failure,
      listener: (ctx, state) {
        if (state.status == SettingsStatus.failure) {
          AppSnackBar.error(ctx, ctx.l10n.errorOccurred);
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (ctx, state) {
          return _SettingsRootView(settings: state.settings);
        },
      ),
    );
  }
}

class _SettingsRootView extends StatefulWidget {
  const _SettingsRootView({required this.settings});

  final Settings settings;

  @override
  State<_SettingsRootView> createState() => _SettingsRootViewState();
}

class _SettingsRootViewState extends State<_SettingsRootView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String _localeLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (widget.settings.locale.languageCode) {
      case 'th':
        return l10n.langThai;
      case 'en':
        return l10n.langEnglish;
      default:
        return widget.settings.locale.languageCode;
    }
  }

  String _themeLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (widget.settings.themeMode) {
      case ThemeMode.light:
        return l10n.settingsThemeLight;
      case ThemeMode.dark:
        return l10n.settingsThemeDark;
      default:
        return l10n.settingsThemeSystem;
    }
  }

  IconData _themeIcon() {
    return switch (widget.settings.themeMode) {
      ThemeMode.light => Icons.wb_sunny,
      ThemeMode.dark => Icons.nights_stay,
      ThemeMode.system => Icons.brightness_auto,
    };
  }

  Color _themeColor() {
    return switch (widget.settings.themeMode) {
      ThemeMode.light => Colors.amber,
      ThemeMode.dark => Colors.indigo,
      ThemeMode.system => Colors.teal,
    };
  }

  ({String label, Color color}) _backupStatus(BuildContext context) {
    final l10n = context.l10n;
    final s = widget.settings;
    if (s.backupReminderDays == 0) {
      return (label: l10n.backupOff, color: context.settingsTheme.mutedText);
    }
    if (s.lastBackupAt == null) {
      return (label: l10n.backupStatusOverdue, color: AppColors.error);
    }
    final last = DateTime.tryParse(s.lastBackupAt!);
    if (last == null) {
      return (label: l10n.backupStatusOverdue, color: AppColors.error);
    }
    final days = DateTime.now().difference(last).inDays;
    if (days <= s.backupReminderDays) {
      return (label: l10n.backupStatusSafe, color: AppColors.success);
    }
    if (days <= s.backupReminderDays * 2) {
      return (label: l10n.backupStatusWarning, color: AppColors.warning);
    }
    return (label: l10n.backupStatusOverdue, color: AppColors.error);
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  List<_SettingsTile> _generalTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      _SettingsTile(
        icon: Icons.settings_outlined,
        title: l10n.settingsGeneral,
        accent: st.softAccent,
        subtitle: '${_localeLabel(context)} · ${_themeLabel(context)}',
        statusChip: SettingsStatusChip(
          label: s.locale.languageCode.toUpperCase(),
          color: st.softAccent,
          st: st,
        ),
        page: const GeneralSettingsPage(),
      ),
      _SettingsTile(
        icon: Icons.image_outlined,
        title: l10n.settingsImages,
        accent: st.softAccent,
        subtitle: '${s.imageMaxWidth}px · ${s.imageQuality}%',
        statusChip: SettingsStatusChip(
          label: '${s.imageMaxWidth}px',
          color: st.softAccent,
          st: st,
        ),
        page: const ImageSettingsPage(),
      ),
      _SettingsTile(
        icon: Icons.qr_code_scanner_outlined,
        title: l10n.barcodeSettings,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.barcodeScanEnabled
              ? l10n.settingsStatusActive
              : l10n.settingsStatusNotSet,
          color: s.barcodeScanEnabled ? AppColors.success : st.mutedText,
          st: st,
        ),
        page: const BarcodeSettingsPage(),
      ),
    ];
  }

  List<_SettingsTile> _storeTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final shopComplete = s.shopName.isNotEmpty && s.phone.isNotEmpty;
    return [
      _SettingsTile(
        icon: Icons.store_outlined,
        title: l10n.settingsShopInfo,
        accent: st.softAccent,
        subtitle: s.shopName.isNotEmpty ? s.shopName : null,
        statusChip: SettingsStatusChip(
          label: shopComplete
              ? l10n.settingsStatusComplete
              : l10n.settingsStatusIncomplete,
          color: shopComplete ? AppColors.success : AppColors.warning,
          st: st,
        ),
        page: const ShopInfoSettingsPage(),
      ),
      _SettingsTile(
        icon: Icons.point_of_sale_outlined,
        title: l10n.settingsSales,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.currency,
          color: st.softAccent,
          st: st,
        ),
        page: const SalesSettingsPage(),
      ),
      _SettingsTile(
        icon: Icons.receipt_long_outlined,
        title: l10n.settingsReceipt,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.receiptSize,
          color: st.softAccent,
          st: st,
        ),
        page: const ReceiptSettingsPage(),
      ),
      _SettingsTile(
        icon: Icons.inventory_2_outlined,
        title: l10n.settingsStockPolicy,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.allowOversell ? 'ON' : '${s.lowStockThreshold}',
          color: s.allowOversell ? AppColors.error : st.softAccent,
          st: st,
        ),
        page: const StockSettingsPage(),
      ),
    ];
  }

  List<_SettingsTile> _discountTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      _SettingsTile(
        icon: Icons.local_offer_outlined,
        title: l10n.settingsDiscountPolicy,
        accent: st.softAccent,
        subtitle:
            '${s.discountPresets.length} ${l10n.discountPresetsTitle.toLowerCase()}',
        statusChip: SettingsStatusChip(
          label: s.activeDiscountPreset.name,
          color: st.softAccent,
          st: st,
        ),
        page: const DiscountPolicySettingsPage(),
      ),
    ];
  }

  List<_SettingsTile> _paymentTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      _SettingsTile(
        icon: Icons.qr_code_2_outlined,
        title: l10n.promptpay,
        accent: st.softAccent,
        subtitle: s.promptpayId.isNotEmpty ? s.promptpayId : null,
        statusChip: SettingsStatusChip(
          label: s.promptpayId.isNotEmpty
              ? l10n.settingsStatusActive
              : l10n.settingsStatusNotSet,
          color: s.promptpayId.isNotEmpty ? AppColors.success : st.mutedText,
          st: st,
        ),
        page: const PromptpaySettingsPage(),
      ),
    ];
  }

  List<_SettingsTile> _systemTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final backup = _backupStatus(context);
    return [
      _SettingsTile(
        icon: Icons.lock_clock_outlined,
        title: l10n.settingsDailyCloseTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDailyCloseSubtitle,
        statusChip: SettingsStatusChip(
          label: l10n.closeDay,
          color: st.softAccent,
          st: st,
        ),
        page: const DailyCloseListPage(),
      ),
      _SettingsTile(
        icon: Icons.backup_outlined,
        title: l10n.settingsBackup,
        accent: st.softAccent,
        subtitle: s.backupReminderDays == 0
            ? l10n.backupOff
            : l10n.backupEveryNDays(s.backupReminderDays),
        statusChip: SettingsStatusChip(
          label: backup.label,
          color: backup.color,
          st: st,
        ),
        page: const BackupSettingsPage(),
      ),
      _SettingsTile(
        icon: Icons.storage_outlined,
        title: l10n.settingsDbHealthTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDbHealthSubtitle,
        statusChip: SettingsStatusChip(
          label: l10n.dbHealthTitle,
          color: st.softAccent,
          st: st,
        ),
        page: const DbHealthPage(),
      ),
    ];
  }

  List<_SettingsTile> _aboutTiles(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      _SettingsTile(
        icon: Icons.info_outline,
        title: l10n.aboutApp,
        accent: st.softAccent,
        subtitle: l10n.agplShort,
        page: const AboutPage(),
      ),
    ];
  }

  List<_SettingsSection> _allSections(
    BuildContext context,
    Settings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      _SettingsSection(
        title: l10n.settingsGeneral,
        tiles: _generalTiles(context, s, st, l10n),
      ),
      _SettingsSection(
        title: l10n.settingsStoreSales,
        tiles: _storeTiles(context, s, st, l10n),
      ),
      _SettingsSection(
        title: l10n.settingsDiscounts,
        tiles: _discountTiles(context, s, st, l10n),
      ),
      _SettingsSection(
        title: l10n.settingsPayments,
        tiles: _paymentTiles(context, s, st, l10n),
      ),
      _SettingsSection(
        title: l10n.settingsSystemData,
        tiles: _systemTiles(context, s, st, l10n),
      ),
      _SettingsSection(
        title: l10n.settingsAbout,
        tiles: _aboutTiles(context, s, st, l10n),
      ),
    ];
  }

  Widget _animatedTile(_SettingsTile tile, int index) {
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(
        (index * 0.04).clamp(0.0, 1.0),
        1.0,
        curve: Curves.easeOutCubic,
      ),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: SettingsCategoryTile(
          icon: tile.icon,
          title: tile.title,
          subtitle: tile.subtitle,
          accentColor: tile.accent,
          statusChip: tile.statusChip,
          onTap: () => _push(context, tile.page),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final s = widget.settings;

    final sections = _allSections(context, s, st, l10n);

    final showGrouped = _query.isEmpty && !_isSearching;

    final filteredSections = showGrouped
        ? sections
        : sections
              .map(
                (sec) => _SettingsSection(
                  title: sec.title,
                  tiles: sec.tiles.where((t) {
                    final text = '${t.title} ${t.subtitle ?? ''} ${sec.title}'
                        .toLowerCase();
                    return text.contains(_query);
                  }).toList(),
                ),
              )
              .where((sec) => sec.tiles.isNotEmpty)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.searchSettings,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                style: Theme.of(context).textTheme.titleMedium,
              )
            : Text(l10n.settingsTitle),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _query = '';
                } else {
                  _searchFocus.requestFocus();
                }
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          if (showGrouped) ...[
            SettingsDashboardCard(
              settings: s,
              localeLabel: _localeLabel(context),
              themeLabel: _themeLabel(context),
              themeIcon: _themeIcon(),
              themeColor: _themeColor(),
              backupStatus: _backupStatus(context),
              st: st,
              onLocaleToggle: () {
                final cubit = context.read<SettingsCubit>();
                final next = s.locale.languageCode == 'th'
                    ? const Locale('en')
                    : const Locale('th');
                cubit.updateField((_) => s.copyWith(locale: next));
              },
              onThemeToggle: () {
                final cubit = context.read<SettingsCubit>();
                final next = switch (s.themeMode) {
                  ThemeMode.light => ThemeMode.dark,
                  ThemeMode.dark => ThemeMode.system,
                  ThemeMode.system => ThemeMode.light,
                };
                cubit.updateField((_) => s.copyWith(themeMode: next));
              },
            ),
            const SizedBox(height: 24),
          ],
          if (filteredSections.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  l10n.noSearchResults,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: st.mutedText),
                ),
              ),
            )
          else
            ...filteredSections.asMap().entries.expand((entry) {
              final sectionIndex = entry.key;
              final sec = entry.value;
              final tileStartIndex = sections
                  .sublist(0, sectionIndex)
                  .fold<int>(0, (sum, s) => sum + s.tiles.length);
              return [
                SettingsSectionCard(
                  title: sec.title,
                  children: sec.tiles.asMap().entries.map((tileEntry) {
                    final globalIndex = tileStartIndex + tileEntry.key;
                    return _animatedTile(tileEntry.value, globalIndex);
                  }).toList(),
                ),
                const SizedBox(height: 24),
              ];
            }),
        ],
      ),
    );
  }
}

class _SettingsTile {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.statusChip,
    required this.page,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;
  final Widget? statusChip;
  final Widget page;
}

class _SettingsSection {
  const _SettingsSection({required this.title, required this.tiles});

  final String title;
  final List<_SettingsTile> tiles;
}
