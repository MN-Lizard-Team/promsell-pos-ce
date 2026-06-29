import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/image_settings_labels.dart';

class ImageQualityTile extends StatelessWidget {
  const ImageQualityTile({
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
        qualityLabel(settings.imageQuality),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: st.softTextSecondary,
          fontSize: 14,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${settings.imageQuality}%',
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
      onTap: () => _showQualityDialog(context),
    );
  }

  void _showQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _QualityDialog(settings: settings, cubit: cubit),
    );
  }
}

class _QualityDialog extends StatefulWidget {
  const _QualityDialog({required this.settings, required this.cubit});

  final Settings settings;
  final SettingsCubit cubit;

  @override
  State<_QualityDialog> createState() => _QualityDialogState();
}

class _QualityDialogState extends State<_QualityDialog> {
  late final _ctrl = TextEditingController(
    text: widget.settings.imageQuality.toString(),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsImageQuality),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              controller: _ctrl,
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
                  (50, l10n.imageQualityDraft),
                  (70, l10n.imageQualityStandard),
                  (80, l10n.imageQualityHigh),
                  (90, l10n.imageQualityBest),
                  (100, l10n.imageQualityOriginal),
                ].map((preset) {
                  final (value, label) = preset;
                  return ChoiceChip(
                    label: Text('$label ($value%)'),
                    selected: false,
                    onSelected: (_) {
                      _ctrl.text = '$value';
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
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final n = int.tryParse(_ctrl.text.trim());
            if (n != null) {
              widget.cubit.updateField(
                (s) => s.copyWith(imageQuality: n.clamp(1, 100)),
              );
            }
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(backgroundColor: st.softAccent),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
