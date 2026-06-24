import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/image_settings_labels.dart';

class ImageWidthTile extends StatelessWidget {
  const ImageWidthTile({
    super.key,
    required this.settings,
    required this.cubit,
  });

  final Settings settings;
  final SettingsCubit cubit;

  @override
  Widget build(BuildContext context) {
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
        widthLabel(settings.imageMaxWidth),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: st.softTextSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${settings.imageMaxWidth}px',
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
      onTap: () => _showWidthDialog(context),
    );
  }

  void _showWidthDialog(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final ctrl = TextEditingController(text: settings.imageMaxWidth.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsImageMaxWidth),
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
                    (400, l10n.imageWidthSmall),
                    (600, l10n.imageWidthMedium),
                    (800, l10n.imageWidthLarge),
                    (1200, l10n.imageWidthExtraLarge),
                    (1600, l10n.imageWidthFullHD),
                  ].map((preset) {
                    final (value, label) = preset;
                    return ChoiceChip(
                      label: Text('$label ($value)'),
                      selected: false,
                      onSelected: (_) {
                        ctrl.text = '$value';
                      },
                      selectedColor: st.activeAccentContainer,
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
            child: Text(l10n.cancel),
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
            child: Text(l10n.save),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}
