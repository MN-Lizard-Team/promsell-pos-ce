import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_category_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/general_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/sales_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/receipt_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/discount_policy_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/discount_presets_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/stock_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/image_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/pages/daily_close_list_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/db_health_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/promptpay_settings_page.dart';

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

  final AppSettings settings;

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
      return (label: l10n.backupStatusOverdue, color: Colors.red);
    }
    final last = DateTime.tryParse(s.lastBackupAt!);
    if (last == null) {
      return (label: l10n.backupStatusOverdue, color: Colors.red);
    }
    final days = DateTime.now().difference(last).inDays;
    if (days <= s.backupReminderDays) {
      return (label: l10n.backupStatusSafe, color: Colors.green);
    }
    if (days <= s.backupReminderDays * 2) {
      return (label: l10n.backupStatusWarning, color: Colors.orange);
    }
    return (label: l10n.backupStatusOverdue, color: Colors.red);
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final s = widget.settings;

    final storeBusiness = _storeBusinessItems(context, s, st, l10n);
    final payments = _paymentsItems(context, s, st, l10n);
    final system = _systemItems(context, s, st, l10n);
    final all = [...storeBusiness, ...payments, ...system];

    final filtered = _query.isEmpty
        ? all
        : all.where((c) {
            final text = '${c.title} ${c.subtitle ?? ''}'.toLowerCase();
            return text.contains(_query);
          }).toList();

    final showGrouped = _query.isEmpty && !_isSearching;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search settings...',
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
            _SettingsDashboardCard(
              settings: s,
              localeLabel: _localeLabel(context),
              themeLabel: _themeLabel(context),
              themeIcon: _themeIcon(),
              themeColor: _themeColor(),
              backupStatus: _backupStatus(context),
              st: st,
              l10n: l10n,
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
          if (showGrouped) ...[
            if (storeBusiness.isNotEmpty)
              SettingsSectionCard(
                title: l10n.settingsStoreBusiness,
                children: storeBusiness.map((c) => _animatedTile(c)).toList(),
              ),
            if (storeBusiness.isNotEmpty) const SizedBox(height: 24),
            if (payments.isNotEmpty)
              SettingsSectionCard(
                title: l10n.settingsPayments,
                children: payments.map((c) => _animatedTile(c)).toList(),
              ),
            if (payments.isNotEmpty) const SizedBox(height: 24),
            if (system.isNotEmpty)
              SettingsSectionCard(
                title: l10n.settingsSystemData,
                children: system.map((c) => _animatedTile(c)).toList(),
              ),
          ] else
            ...filtered.map((c) => _animatedTile(c)),
        ],
      ),
    );
  }

  Widget _animatedTile(_CategoryItem cat) {
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(cat.index * 0.04, 1.0, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: SettingsCategoryTile(
          icon: cat.icon,
          title: cat.title,
          subtitle: cat.subtitle,
          accentColor: cat.accent,
          statusChip: cat.statusChip,
          onTap: () => _push(context, cat.page),
        ),
      ),
    );
  }

  List<_CategoryItem> _storeBusinessItems(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final shopComplete = s.shopName.isNotEmpty && s.phone.isNotEmpty;
    return [
      _CategoryItem(
        index: 0,
        icon: Icons.store_outlined,
        title: l10n.settingsShopInfo,
        accent: st.softAccent,
        subtitle: s.shopName.isNotEmpty ? s.shopName : null,
        statusChip: _StatusChip(
          label: shopComplete
              ? l10n.settingsStatusComplete
              : l10n.settingsStatusIncomplete,
          color: shopComplete ? Colors.green : Colors.orange,
          st: st,
        ),
        page: const ShopInfoSettingsPage(),
      ),
      _CategoryItem(
        index: 1,
        icon: Icons.point_of_sale_outlined,
        title: l10n.settingsSales,
        accent: st.softAccent,
        statusChip: _StatusChip(
          label: s.currency,
          color: st.softAccent,
          st: st,
        ),
        page: const SalesSettingsPage(),
      ),
      _CategoryItem(
        index: 2,
        icon: Icons.receipt_long_outlined,
        title: l10n.settingsReceipt,
        accent: st.softAccent,
        statusChip: _StatusChip(
          label: s.receiptSize,
          color: st.softAccent,
          st: st,
        ),
        page: const ReceiptSettingsPage(),
      ),
      _CategoryItem(
        index: 3,
        icon: Icons.local_offer_outlined,
        title: l10n.settingsDiscountPolicy,
        accent: st.softAccent,
        statusChip: _StatusChip(
          label: s.activeDiscountPreset.name,
          color: st.softAccent,
          st: st,
        ),
        page: const DiscountPolicySettingsPage(),
      ),
      _CategoryItem(
        index: 4,
        icon: Icons.discount_outlined,
        title: l10n.discountPresetsTitle,
        accent: st.softAccent,
        statusChip: _StatusChip(
          label: '${s.discountPresets.length}',
          color: st.softAccent,
          st: st,
        ),
        page: const DiscountPresetsPage(),
      ),
      _CategoryItem(
        index: 5,
        icon: Icons.inventory_2_outlined,
        title: l10n.settingsStockPolicy,
        accent: st.softAccent,
        statusChip: _StatusChip(
          label: s.allowOversell ? 'ON' : '${s.lowStockThreshold}',
          color: s.allowOversell ? Colors.red : st.softAccent,
          st: st,
        ),
        page: const StockSettingsPage(),
      ),
    ];
  }

  List<_CategoryItem> _paymentsItems(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      _CategoryItem(
        index: 6,
        icon: Icons.qr_code_2_outlined,
        title: l10n.promptpay,
        accent: st.softAccent,
        subtitle: s.promptpayId.isNotEmpty ? s.promptpayId : null,
        statusChip: _StatusChip(
          label: s.promptpayId.isNotEmpty
              ? l10n.settingsStatusActive
              : l10n.settingsStatusNotSet,
          color: s.promptpayId.isNotEmpty ? Colors.green : st.mutedText,
          st: st,
        ),
        page: const PromptpaySettingsPage(),
      ),
    ];
  }

  List<_CategoryItem> _systemItems(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final backup = _backupStatus(context);
    return [
      _CategoryItem(
        index: 7,
        icon: Icons.lock_clock_outlined,
        title: l10n.settingsDailyCloseTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDailyCloseSubtitle,
        statusChip: _StatusChip(
          label: l10n.closeDay,
          color: st.softAccent,
          st: st,
        ),
        page: const DailyCloseListPage(),
      ),
      _CategoryItem(
        index: 8,
        icon: Icons.settings_outlined,
        title: l10n.settingsGeneral,
        accent: st.softAccent,
        subtitle: '${_localeLabel(context)} · ${_themeLabel(context)}',
        statusChip: _StatusChip(
          label: s.locale.languageCode.toUpperCase(),
          color: st.softAccent,
          st: st,
        ),
        page: const GeneralSettingsPage(),
      ),
      _CategoryItem(
        index: 9,
        icon: Icons.image_outlined,
        title: l10n.settingsImages,
        accent: st.softAccent,
        subtitle: '${s.imageMaxWidth}px · ${s.imageQuality}%',
        statusChip: _StatusChip(
          label: '${s.imageMaxWidth}px',
          color: st.softAccent,
          st: st,
        ),
        page: const ImageSettingsPage(),
      ),
      _CategoryItem(
        index: 10,
        icon: Icons.backup_outlined,
        title: l10n.settingsBackup,
        accent: st.softAccent,
        subtitle: s.backupReminderDays == 0
            ? l10n.backupOff
            : l10n.backupEveryNDays(s.backupReminderDays),
        statusChip: _StatusChip(
          label: backup.label,
          color: backup.color,
          st: st,
        ),
        page: const BackupSettingsPage(),
      ),
      _CategoryItem(
        index: 11,
        icon: Icons.storage_outlined,
        title: l10n.settingsDbHealthTitle,
        accent: st.softAccent,
        subtitle: l10n.settingsDbHealthSubtitle,
        statusChip: _StatusChip(
          label: l10n.dbHealthTitle,
          color: st.softAccent,
          st: st,
        ),
        page: const DbHealthPage(),
      ),
    ];
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.index,
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.statusChip,
    required this.page,
  });

  final int index;
  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;
  final Widget? statusChip;
  final Widget page;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.st,
  });

  final String label;
  final Color color;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SettingsDashboardCard extends StatelessWidget {
  const _SettingsDashboardCard({
    required this.settings,
    required this.localeLabel,
    required this.themeLabel,
    required this.themeIcon,
    required this.themeColor,
    required this.backupStatus,
    required this.st,
    required this.l10n,
    this.onLocaleToggle,
    this.onThemeToggle,
  });

  final AppSettings settings;
  final String localeLabel;
  final String themeLabel;
  final IconData themeIcon;
  final Color themeColor;
  final ({String label, Color color}) backupStatus;
  final SettingsThemeExtension st;
  final AppLocalizations l10n;
  final VoidCallback? onLocaleToggle;
  final VoidCallback? onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shopName = settings.shopName.isNotEmpty ? settings.shopName : '—';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            st.softAccent.withValues(alpha: 0.35),
            st.softAccent.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(
          color: st.softAccent.withValues(alpha: 0.50),
          width: 1,
        ),
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
              Icons.settings_outlined,
              color: st.softAccent,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.settingsTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _DashboardBadge(
                icon: Icons.store_outlined,
                label: shopName,
                color: settings.shopName.isNotEmpty
                    ? st.softAccent
                    : st.mutedText,
                st: st,
              ),
              _DashboardBadge(
                icon: Icons.language_outlined,
                label: localeLabel,
                color: st.softAccent,
                st: st,
                onTap: onLocaleToggle,
              ),
              _DashboardBadge(
                icon: themeIcon,
                label: themeLabel,
                color: themeColor,
                st: st,
                onTap: onThemeToggle,
              ),
              _DashboardBadge(
                icon: Icons.backup_outlined,
                label: backupStatus.label,
                color: backupStatus.color,
                st: st,
              ),
              _DashboardBadge(
                icon: Icons.qr_code_2,
                label: settings.promptpayId.isNotEmpty
                    ? l10n.settingsStatusActive
                    : l10n.settingsStatusNotSet,
                color: settings.promptpayId.isNotEmpty
                    ? st.softAccent
                    : st.mutedText,
                st: st,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardBadge extends StatelessWidget {
  const _DashboardBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.st,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final SettingsThemeExtension st;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.50), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return badge;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: badge,
      ),
    );
  }
}
