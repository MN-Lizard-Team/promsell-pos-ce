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

class ImageSettingsPage extends StatelessWidget {
  const ImageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();

        return Scaffold(
          appBar: AppBar(title: Text(context.l10n.settingsImages)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              ImagePreviewCard(
                imageMaxWidth: s.imageMaxWidth,
                imageQuality: s.imageQuality,
              ),
              const SizedBox(height: 24),
              DemoImagePreview(
                width: s.imageMaxWidth,
                quality: s.imageQuality,
                st: context.settingsTheme,
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: context.l10n.settingsImages,
                children: [
                  ImageWidthTile(settings: s, cubit: cubit),
                  ImageQualityTile(settings: s, cubit: cubit),
                ],
              ),
              const SizedBox(height: 24),
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
