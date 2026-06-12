import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/clear_orphaned_images.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/demo_image_preview.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image_settings_labels.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';

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
                  _buildWidthTile(context, s, cubit),
                  _buildQualityTile(context, s, cubit),
                ],
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildClearCacheButton(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWidthTile(
    BuildContext context,
    AppSettings s,
    SettingsCubit cubit,
  ) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.width_normal_outlined,
          color: st.softAccent,
          size: 24,
        ),
      ),
      title: Text(
        l10n.settingsImageMaxWidth,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        widthLabel(s.imageMaxWidth),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: st.softTextSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${s.imageMaxWidth}px',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: st.softTextPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 24),
        ],
      ),
      onTap: () => _showWidthDialog(context, s, cubit),
    );
  }

  void _showWidthDialog(
    BuildContext context,
    AppSettings s,
    SettingsCubit cubit,
  ) {
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: s.imageMaxWidth.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsImageMaxWidth),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    (400, context.l10n.imageWidthSmall),
                    (600, context.l10n.imageWidthMedium),
                    (800, context.l10n.imageWidthLarge),
                    (1200, context.l10n.imageWidthExtraLarge),
                    (1600, context.l10n.imageWidthFullHD),
                  ].map((preset) {
                    final (value, label) = preset;
                    return ChoiceChip(
                      label: Text('$label ($value)'),
                      selected: false,
                      onSelected: (_) {
                        ctrl.text = '$value';
                      },
                      selectedColor: st.softAccentContainer,
                      backgroundColor: st.cardBackground,
                      side: BorderSide(color: st.cardBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n != null) {
                cubit.updateField(
                  (s) => s.copyWith(imageMaxWidth: n.clamp(100, 3000)),
                );
              }
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityTile(
    BuildContext context,
    AppSettings s,
    SettingsCubit cubit,
  ) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.high_quality_outlined,
          color: st.softAccent,
          size: 24,
        ),
      ),
      title: Text(
        l10n.settingsImageQuality,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        qualityLabel(s.imageQuality),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: st.softTextSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${s.imageQuality}%',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: st.softTextPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: st.softTextSecondary, size: 24),
        ],
      ),
      onTap: () => _showQualityDialog(context, s, cubit),
    );
  }

  void _showQualityDialog(
    BuildContext context,
    AppSettings s,
    SettingsCubit cubit,
  ) {
    final st = context.settingsTheme;
    final ctrl = TextEditingController(text: s.imageQuality.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsImageQuality),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    (50, context.l10n.imageQualityDraft),
                    (70, context.l10n.imageQualityStandard),
                    (80, context.l10n.imageQualityHigh),
                    (90, context.l10n.imageQualityBest),
                    (100, context.l10n.imageQualityOriginal),
                  ].map((preset) {
                    final (value, label) = preset;
                    return ChoiceChip(
                      label: Text('$label ($value%)'),
                      selected: false,
                      onSelected: (_) {
                        ctrl.text = '$value';
                      },
                      selectedColor: st.softAccentContainer,
                      backgroundColor: st.cardBackground,
                      side: BorderSide(color: st.cardBorderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n != null) {
                cubit.updateField(
                  (s) => s.copyWith(imageQuality: n.clamp(1, 100)),
                );
              }
              Navigator.of(ctx).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildClearCacheButton(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return OutlinedButton.icon(
      icon: const Icon(Icons.delete_sweep_outlined),
      label: Text(l10n.clearImageCache),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        side: BorderSide(color: theme.colorScheme.error),
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.clearImageCache),
            content: Text(l10n.clearImageCacheConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final usecase = GetIt.I<ClearOrphanedImages>();
        final deleted = await usecase();
        if (context.mounted) {
          AppSnackBar.success(
            context,
            '${l10n.imageCacheCleared} ($deleted files)',
          );
        }
      },
    );
  }
}
