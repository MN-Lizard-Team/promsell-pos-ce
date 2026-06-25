import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_dashboard_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_builders.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_data.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_category_tile.dart';

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

  Widget _animatedTile(SettingsTileData tile, int index) {
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

    final sections = SettingsTileBuilders.allSections(context, s, st, l10n);

    final showGrouped = _query.isEmpty && !_isSearching;

    final filteredSections = showGrouped
        ? sections
        : sections
              .map(
                (sec) => SettingsSectionData(
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
                    color: Theme.of(context).colorScheme.secondary,
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
              localeLabel: SettingsTileBuilders.localeLabel(context, s),
              themeLabel: SettingsTileBuilders.themeLabel(context, s),
              themeIcon: SettingsTileBuilders.themeIcon(s),
              themeColor: SettingsTileBuilders.themeColor(s),
              backupStatus: SettingsTileBuilders.backupStatus(context, s),
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
