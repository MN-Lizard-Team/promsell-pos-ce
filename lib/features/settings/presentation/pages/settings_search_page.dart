import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_app_bar_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_builders.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_header.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_action_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Full-screen settings search — opened from the root dashboard's search
/// strip (same pattern as the Sale product search page). Filters sections by
/// tile title, subtitle, section title, and extra keywords; results keep the
/// section grouping so hits stay in context.
class SettingsSearchPage extends StatefulWidget {
  const SettingsSearchPage({super.key});

  @override
  State<SettingsSearchPage> createState() => _SettingsSearchPageState();
}

class _SettingsSearchPageState extends State<SettingsSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    disposeTextEditingControllerAfterFrame(_searchController);
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _query = query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final settings = context.read<SettingsCubit>().state.settings;

    final sections = SettingsTileBuilders.filterSections(
      SettingsTileBuilders.allSections(context, settings, st, l10n),
      _query,
    );

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SearchAppBarField(
            controller: _searchController,
            focusNode: _focusNode,
            hintText: l10n.searchSettings,
            onChanged: _onSearchChanged,
            onClear: _clearSearch,
            showClear: _query.isNotEmpty,
          ),
        ),
      ),
      body: sections.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: AppEmptyState(
                icon: TablerIcons.searchOff,
                title: l10n.noSearchResults,
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 16),
              children: [
                for (final section in sections) ...[
                  SettingsSectionHeader(section.title),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        for (var i = 0; i < section.tiles.length; i++) ...[
                          SettingsActionCard(
                            icon: section.tiles[i].icon,
                            title: section.tiles[i].title,
                            subtitle: section.tiles[i].subtitle,
                            accentColor: section.tiles[i].accent,
                            statusBadge: section.tiles[i].statusChip,
                            emphasized: section.tiles[i].emphasized,
                            onTap: () => pushSettingsSubPage(
                              context,
                              section.tiles[i].page,
                            ),
                          ),
                          if (i != section.tiles.length - 1)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: st.sectionGap),
                ],
              ],
            ),
    );
  }
}
