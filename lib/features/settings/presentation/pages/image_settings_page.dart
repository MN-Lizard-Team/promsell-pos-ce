import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/image_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/clear_image_cache_button.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/image_quality_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image/image_width_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/demo_image_preview.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_state_view.dart';

class ImageSettingsPage extends StatefulWidget {
  const ImageSettingsPage({super.key});

  @override
  State<ImageSettingsPage> createState() => _ImageSettingsPageState();
}

class _ImageSettingsPageState extends State<ImageSettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.settings != curr.settings || prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();

        return SettingsStateView(
          state: state,
          onRetry: cubit.load,
          builder: (s) => SettingsLeafChrome(
            title: context.l10n.settingsImages,
            header: ImagePreviewCard(
              imageMaxWidth: s.imageMaxWidth,
              imageQuality: s.imageQuality,
            ),
            children: [
              DemoImagePreview(
                width: s.imageMaxWidth,
                quality: s.imageQuality,
                st: context.settingsTheme,
              ),
              SettingsSectionCard(
                title: context.l10n.settingsImages,
                children: [
                  ImageWidthTile(settings: s, cubit: cubit),
                  ImageQualityTile(settings: s, cubit: cubit),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ClearImageCacheButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}
