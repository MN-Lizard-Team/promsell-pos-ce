import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
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
              _ImagePreviewCard(
                imageMaxWidth: s.imageMaxWidth,
                imageQuality: s.imageQuality,
              ),
              const SizedBox(height: 24),
              _DemoImagePreview(
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
        _widthLabel(s.imageMaxWidth),
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
        _qualityLabel(s.imageQuality),
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
}

class _DemoImagePreview extends StatelessWidget {
  const _DemoImagePreview({
    required this.width,
    required this.quality,
    required this.st,
  });

  final int width;
  final int quality;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayWidth = (width / 1600 * 240).clamp(80.0, 240.0);
    final displayHeight = displayWidth * 0.75;
    final roughKb = ((width * width) / 3000 * quality / 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: displayWidth,
              height: displayHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    st.softAccent.withValues(alpha: 0.25),
                    st.softAccent.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Image.asset(
                'assets/images/demo/demo_image_01.png',
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTag(
                icon: Icons.width_normal_outlined,
                label: '$width px',
                st: st,
              ),
              const SizedBox(width: 8),
              _buildTag(
                icon: Icons.high_quality_outlined,
                label: _qualityLabel(quality),
                st: st,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '~$roughKb KB · ${l10n.imageExample}',
            style: TextStyle(
              fontSize: 12,
              color: st.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required SettingsThemeExtension st,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: st.iconContainerBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: st.softAccent, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: st.softTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

String _qualityLabel(int quality) {
  if (quality <= 50) return 'Draft quality';
  if (quality <= 70) return 'Standard quality';
  if (quality <= 80) return 'High quality';
  if (quality <= 90) return 'Best quality';
  return 'Original quality';
}

String _widthLabel(int width) {
  if (width <= 400) return 'Small size';
  if (width <= 600) return 'Medium size';
  if (width <= 800) return 'Large size';
  if (width <= 1200) return 'Extra large size';
  return 'Full HD size';
}

class _ImagePreviewCard extends StatelessWidget {
  const _ImagePreviewCard({
    required this.imageMaxWidth,
    required this.imageQuality,
  });

  final int imageMaxWidth;
  final int imageQuality;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final l10n = context.l10n;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
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
            child: Icon(Icons.image_outlined, color: st.softAccent, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            '${l10n.settingsImages} Preview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildRow(
            icon: Icons.width_normal_outlined,
            label: l10n.settingsImageMaxWidth,
            value: _widthLabel(imageMaxWidth),
            st: st,
          ),
          _buildRow(
            icon: Icons.high_quality_outlined,
            label: l10n.settingsImageQuality,
            value: _qualityLabel(imageQuality),
            st: st,
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required String value,
    required SettingsThemeExtension st,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: st.softAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, color: st.softTextSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: st.softTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
