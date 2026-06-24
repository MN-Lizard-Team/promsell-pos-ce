import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class BackupReminderDialog {
  BackupReminderDialog._();

  static void show(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final ctrl = TextEditingController(text: s.backupReminderDays.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupFrequency),
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
                    (7, l10n.backupWeekly),
                    (14, l10n.backupBiweekly),
                    (30, l10n.backupMonthly),
                    (60, l10n.backupBimonthly),
                    (90, l10n.backupQuarterly),
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
              if (n != null && n >= 0) {
                cubit.updateField((s) => s.copyWith(backupReminderDays: n));
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
