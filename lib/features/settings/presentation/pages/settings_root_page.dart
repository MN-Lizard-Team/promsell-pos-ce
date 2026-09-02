import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/pages/table_management_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/core/widgets/layout/adaptive_breakpoints.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/app_lock_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/promptpay_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_search_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_builders.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_data.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_header.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_state_view.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_action_card.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

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
        buildWhen: (prev, curr) =>
            prev.settings != curr.settings || prev.status != curr.status,
        builder: (ctx, state) {
          return SettingsStateView(
            state: state,
            onRetry: ctx.read<SettingsCubit>().load,
            builder: (settings) => _SettingsRootView(settings: settings),
          );
        },
      ),
    );
  }
}

/// One merchant-readiness item. This is the single source of truth shared by
/// the compact hero summary and the attention chips below it, so the two can
/// never disagree about what is done or missing.
class _ReadinessCheck {
  const _ReadinessCheck({
    required this.label,
    required this.done,
    required this.icon,
    required this.page,
    required this.highPriority,
  });

  final String label;
  final bool done;
  final IconData icon;
  final Widget page;

  /// Backup-overdue is an error-grade gap; other gaps are warnings.
  final bool highPriority;
}

List<_ReadinessCheck> _readinessChecks({
  required Settings s,
  required bool pinConfigured,
  required AppLocalizations l10n,
}) {
  return [
    _ReadinessCheck(
      label: l10n.settingsShopInfo,
      done: s.shopInfo.isComplete,
      icon: TablerIcons.buildingStore,
      page: const ShopInfoSettingsPage(),
      highPriority: false,
    ),
    _ReadinessCheck(
      label: l10n.promptpay,
      done: s.promptpayId.isNotEmpty,
      icon: TablerIcons.qrcode,
      page: const PromptpaySettingsPage(),
      highPriority: false,
    ),
    // Ready only when a backup exists AND it is inside the reminder window.
    // Reminders turned off still count until a first backup exists, so the
    // checklist keeps nudging instead of silently passing.
    _ReadinessCheck(
      label: l10n.settingsBackup,
      done: s.lastBackupAt != null && !s.backupConfig.isOverdue,
      icon: TablerIcons.databaseExport,
      page: const BackupSettingsPage(),
      highPriority: true,
    ),
    _ReadinessCheck(
      label: l10n.appLockTitle,
      done: pinConfigured,
      icon: TablerIcons.lock,
      page: const AppLockSettingsPage(),
      highPriority: false,
    ),
  ];
}

/// Compact readiness header: shop name, an "x/y" counter over a thin progress
/// bar, and a one-line list of what is still missing. Deliberately small so
/// the first screen belongs to actual settings, not dashboard chrome.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.checks,
    required this.shopNameFallback,
    required this.onOpen,
  });

  final List<_ReadinessCheck> checks;
  final String shopNameFallback;
  final void Function(Widget page) onOpen;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final doneCount = checks.where((c) => c.done).length;
    final total = checks.length;
    final pending = checks.where((c) => !c.done).toList();
    final notDone = pending.map((c) => c.label).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(st.cardRadius),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          // Deep-link to the first pending item; Shop Info when all done.
          onTap: () => onOpen(
            pending.isEmpty ? const ShopInfoSettingsPage() : pending.first.page,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Semantics(
              container: true,
              button: true,
              label:
                  '${notDone.isEmpty ? '' : '${notDone.join(' · ')}. '}'
                  '$doneCount/$total',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          shopNameFallback.isEmpty
                              ? l10n.settingsShopInfo
                              : shopNameFallback,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$doneCount/$total',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(st.pillRadius),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : doneCount / total,
                      minHeight: st.heroProgressHeight,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  if (notDone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      notDone.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pending-readiness chips. Each chip deep-links straight to its own sub-page.
class _AttentionStrip extends StatelessWidget {
  const _AttentionStrip({required this.checks, required this.onOpen});

  final List<_ReadinessCheck> checks;
  final void Function(Widget page) onOpen;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final pending = checks.where((c) => !c.done).toList();
    if (pending.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        // Wrap, not a horizontal scroll: at most four readiness chips exist,
        // so everything stays visible without a hidden swipe affordance.
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final check in pending)
              Builder(
                builder: (context) {
                  final tone = check.highPriority
                      ? st.statusErrorText
                      : st.statusWarningText;
                  return Semantics(
                    button: true,
                    label: check.label,
                    child: ActionChip(
                      onPressed: () => onOpen(check.page),
                      avatar: Icon(check.icon, size: 16, color: tone),
                      label: Text(
                        check.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: tone,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: tone.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: tone.withValues(alpha: st.badgeBorderAlpha),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          st.statusBadgeRadius,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// 2-column (wide) or 1-column (phone) grid of action cards for a section.
class _ActionCardGrid extends StatelessWidget {
  const _ActionCardGrid({required this.tiles, required this.onTap});

  final List<SettingsTileData> tiles;
  final void Function(Widget page) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 480;
        if (!isWide) {
          return Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                _card(tiles[i]),
                if (i != tiles.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < tiles.length; i += 2) {
          final left = tiles[i];
          final right = i + 1 < tiles.length ? tiles[i + 1] : null;
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _card(left)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: right != null
                        ? _card(right)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
          if (i + 2 < tiles.length) {
            rows.add(const SizedBox(height: 10));
          }
        }
        return Column(children: rows);
      },
    );
  }

  Widget _card(SettingsTileData tile) {
    return SettingsActionCard(
      icon: tile.icon,
      title: tile.title,
      subtitle: tile.subtitle,
      accentColor: tile.accent,
      statusBadge: tile.statusChip,
      emphasized: tile.emphasized,
      onTap: () => onTap(tile.page),
    );
  }
}

/// Pushes a settings sub-page with the shared slide transition, wrapping
/// pages that need DI-provided blocs (TableManagementPage). Shared by the
/// root dashboard and the settings search page.
void pushSettingsSubPage(BuildContext context, Widget page) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, animation, secondaryAnimation) {
        // TableManagementPage needs a TableBloc the shell doesn't provide —
        // share the DI singleton and trigger the initial load (mirrors the
        // checkout flow).
        if (page is TableManagementPage) {
          return BlocProvider<TableBloc>.value(
            value: sl<TableBloc>()..add(const TablesLoaded()),
            child: page,
          );
        }
        return page;
      },
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

class _SettingsRootView extends StatefulWidget {
  const _SettingsRootView({required this.settings});

  final Settings settings;

  @override
  State<_SettingsRootView> createState() => _SettingsRootViewState();
}

class _SettingsRootViewState extends State<_SettingsRootView>
    with AutomaticKeepAliveClientMixin {
  int _activeSection = 0;
  bool _pinConfigured = false;
  List<GlobalKey> _sectionKeys = const [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPinStatus();
  }

  Future<void> _loadPinStatus() async {
    if (!sl.isRegistered<AppLockService>()) return;
    final lock = sl<AppLockService>();
    final enabled = await lock.isEnabled();
    final hasPin = await lock.hasPin();
    if (mounted) setState(() => _pinConfigured = enabled && hasPin);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _push(BuildContext context, Widget page) =>
      pushSettingsSubPage(context, page);

  void _jumpToSection(int index, GlobalKey key) {
    setState(() => _activeSection = index);
    final target = key.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.04,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final s = widget.settings;

    final sections = SettingsTileBuilders.allSections(context, s, st, l10n);

    // Stable keys so rail jumps keep working across rebuilds.
    if (_sectionKeys.length != sections.length) {
      _sectionKeys = List.generate(sections.length, (_) => GlobalKey());
    }

    final useSectionRail =
        MediaQuery.sizeOf(context).width >= AdaptiveBreakpoints.medium &&
        sections.length > 1;
    final clampedActive = _activeSection.clamp(0, sections.length - 1);

    final checks = _readinessChecks(
      s: s,
      pinConfigured: _pinConfigured,
      l10n: l10n,
    );

    // POS-native chrome — same teal AppBar language as SaleAppBar/Product
    // list: primary background, rounded bottom, and a white search strip
    // docked inside the bar.
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        scrolledUnderElevation: 3,
        shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.18),
        toolbarHeight: 64,
        titleSpacing: 16,
        titleTextStyle: TextStyle(
          color: theme.colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'NotoSansThai',
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Text(l10n.settingsTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _push(context, const SettingsSearchPage()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        TablerIcons.search,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.searchSettings,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (useSectionRail)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 4),
                        child: NavigationRail(
                          selectedIndex: clampedActive,
                          onDestinationSelected: (index) =>
                              _jumpToSection(index, _sectionKeys[index]),
                          labelType: NavigationRailLabelType.all,
                          groupAlignment: -0.9,
                          destinations: [
                            for (var i = 0; i < sections.length; i++)
                              NavigationRailDestination(
                                icon: Icon(
                                  sections[i].tiles.isNotEmpty
                                      ? sections[i].tiles.first.icon
                                      : TablerIcons.adjustments,
                                ),
                                selectedIcon: Icon(
                                  sections[i].tiles.isNotEmpty
                                      ? sections[i].tiles.first.icon
                                      : TablerIcons.adjustmentsFilled,
                                ),
                                label: Text(sections[i].title),
                              ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                        children: [
                          _HeroCard(
                            checks: checks,
                            shopNameFallback: s.shopName,
                            onOpen: (page) => _push(context, page),
                          ),
                          _AttentionStrip(
                            checks: checks,
                            onOpen: (page) => _push(context, page),
                          ),
                          ...sections.asMap().entries.expand((entry) {
                            final index = entry.key;
                            final section = entry.value;
                            return [
                              Container(
                                key: _sectionKeys[index],
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SettingsSectionHeader(
                                  section.title,
                                  accent: section.accent,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: _ActionCardGrid(
                                  tiles: section.tiles,
                                  onTap: (page) => _push(context, page),
                                ),
                              ),
                              SizedBox(height: st.sectionGap),
                            ];
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
