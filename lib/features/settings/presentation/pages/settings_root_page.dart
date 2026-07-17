import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_attention_banner.dart';
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

class _SettingsRootViewState extends State<_SettingsRootView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
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

  void _clearSearch() {
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final s = widget.settings;

    final sections = SettingsTileBuilders.allSections(context, s, st, l10n);
    final showGrouped = _query.isEmpty;

    final filteredSections = showGrouped
        ? sections
        : sections
              .map(
                (sec) => SettingsSectionData(
                  title: sec.title,
                  tiles: sec.tiles.where((t) {
                    final keywords = t.searchKeywords.join(' ');
                    final text =
                        '${t.title} ${t.subtitle ?? ''} ${sec.title} $keywords'
                            .toLowerCase();
                    return text.contains(_query);
                  }).toList(),
                ),
              )
              .where((sec) => sec.tiles.isNotEmpty)
              .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchSettings,
                    prefixIcon: const Icon(Icons.search, size: 22),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).deleteButtonTooltip,
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: _clearSearch,
                          ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.55),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.2,
                      ),
                    ),
                  ),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
                  children: [
                    if (showGrouped)
                      SettingsAttentionBanner(
                        settings: s,
                        onOpen: (page) => _push(context, page),
                      ),
                    if (filteredSections.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        child: AppEmptyState(
                          icon: Icons.search_off_outlined,
                          title: l10n.noSearchResults,
                        ),
                      )
                    else
                      ...filteredSections.expand((sec) {
                        return [
                          SettingsSectionCard(
                            title: sec.title,
                            children: sec.tiles.map((tile) {
                              return SettingsCategoryTile(
                                icon: tile.icon,
                                title: tile.title,
                                subtitle: tile.subtitle,
                                accentColor: tile.accent,
                                statusChip: tile.statusChip,
                                onTap: () => _push(context, tile.page),
                              );
                            }).toList(),
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
      ),
    );
  }
}
