import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_category_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_dashboard_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_status_chip.dart';
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
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_sub_topic_page.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final s = widget.settings;

    final topics = _topicGroups(context, s, st, l10n);

    final generalSubs = _generalSubTopics(context, s, st, l10n);
    final storeSubs = _storeSubTopics(context, s, st, l10n);
    final paymentSubs = _paymentSubTopics(context, s, st, l10n);
    final systemSubs = _systemSubTopics(context, s, st, l10n);

    final allSubTopics = [
      ...generalSubs.map(
        (e) => _SubTopicWithGroup(sub: e, group: l10n.settingsGeneral),
      ),
      ...storeSubs.map(
        (e) => _SubTopicWithGroup(sub: e, group: l10n.settingsStoreBusiness),
      ),
      ...paymentSubs.map(
        (e) => _SubTopicWithGroup(sub: e, group: l10n.settingsPayments),
      ),
      ...systemSubs.map(
        (e) => _SubTopicWithGroup(sub: e, group: l10n.settingsSystemData),
      ),
    ];

    final filteredTopics = _query.isEmpty
        ? topics
        : topics.where((c) {
            final text = '${c.title} ${c.subtitle ?? ''}'.toLowerCase();
            return text.contains(_query);
          }).toList();

    final filteredSubs = _query.isEmpty
        ? <_SubTopicWithGroup>[]
        : allSubTopics.where((e) {
            final text = '${e.sub.title} ${e.sub.subtitle ?? ''} ${e.group}'
                .toLowerCase();
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
          ...filteredTopics.map((c) => _animatedTile(c)),
          if (filteredSubs.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...filteredSubs.map((e) => _animatedSubTile(e)),
          ],
        ],
      ),
    );
  }

  Widget _animatedSubTile(_SubTopicWithGroup e) {
    return SettingsCategoryTile(
      icon: e.sub.icon,
      title: e.sub.title,
      subtitle: e.group,
      accentColor: e.sub.accent,
      statusChip: e.sub.statusChip,
      onTap: () => _push(context, e.sub.page),
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
          onTap: () => _push(context, cat.page),
        ),
      ),
    );
  }

  List<SubTopicItem> _storeSubTopics(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final shopComplete = s.shopName.isNotEmpty && s.phone.isNotEmpty;
    return [
      SubTopicItem(
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
      SubTopicItem(
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
      SubTopicItem(
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
      SubTopicItem(
        icon: Icons.local_offer_outlined,
        title: l10n.settingsDiscountPolicy,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: s.activeDiscountPreset.name,
          color: st.softAccent,
          st: st,
        ),
        page: const DiscountPolicySettingsPage(),
      ),
      SubTopicItem(
        icon: Icons.discount_outlined,
        title: l10n.discountPresetsTitle,
        accent: st.softAccent,
        statusChip: SettingsStatusChip(
          label: '${s.discountPresets.length}',
          color: st.softAccent,
          st: st,
        ),
        page: const DiscountPresetsPage(),
      ),
      SubTopicItem(
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

  List<SubTopicItem> _paymentSubTopics(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SubTopicItem(
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

  List<SubTopicItem> _generalSubTopics(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      SubTopicItem(
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
      SubTopicItem(
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
    ];
  }

  List<SubTopicItem> _systemSubTopics(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final backup = _backupStatus(context);
    return [
      SubTopicItem(
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
      SubTopicItem(
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
      SubTopicItem(
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

  List<_CategoryItem> _topicGroups(
    BuildContext context,
    AppSettings s,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    return [
      _CategoryItem(
        index: 0,
        icon: Icons.tune_outlined,
        title: l10n.settingsGeneral,
        accent: st.softAccent,
        subtitle: '${_localeLabel(context)} · ${_themeLabel(context)}',
        page: SettingsSubTopicPage(
          title: l10n.settingsGeneral,
          subTopics: _generalSubTopics(context, s, st, l10n),
        ),
      ),
      _CategoryItem(
        index: 1,
        icon: Icons.store_outlined,
        title: l10n.settingsStoreBusiness,
        accent: st.softAccent,
        subtitle: s.shopName.isNotEmpty ? s.shopName : null,
        page: SettingsSubTopicPage(
          title: l10n.settingsStoreBusiness,
          subTopics: _storeSubTopics(context, s, st, l10n),
        ),
      ),
      _CategoryItem(
        index: 2,
        icon: Icons.payment_outlined,
        title: l10n.settingsPayments,
        accent: st.softAccent,
        subtitle: s.promptpayId.isNotEmpty ? s.promptpayId : null,
        page: SettingsSubTopicPage(
          title: l10n.settingsPayments,
          subTopics: _paymentSubTopics(context, s, st, l10n),
        ),
      ),
      _CategoryItem(
        index: 3,
        icon: Icons.settings_applications_outlined,
        title: l10n.settingsSystemData,
        accent: st.softAccent,
        subtitle: _backupStatus(context).label,
        page: SettingsSubTopicPage(
          title: l10n.settingsSystemData,
          subTopics: _systemSubTopics(context, s, st, l10n),
        ),
      ),
    ];
  }
}

class _SubTopicWithGroup {
  const _SubTopicWithGroup({required this.sub, required this.group});
  final SubTopicItem sub;
  final String group;
}

class _CategoryItem {
  const _CategoryItem({
    required this.index,
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    required this.page,
  });

  final int index;
  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;
  final Widget page;
}
