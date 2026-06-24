import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/barcode_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/barcode/barcode_format_labels.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class BarcodeFormatsTile extends StatelessWidget {
  const BarcodeFormatsTile({
    super.key,
    required this.settings,
    required this.cubit,
    required this.st,
  });

  final Settings settings;
  final SettingsCubit cubit;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final allFormats = BarcodeConfig.defaultAllFormats;
    final selected = settings.barcodeEnabledFormats;

    return ListTile(
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.filter_list_outlined, color: st.softAccent, size: 24),
      ),
      title: Text(
        l10n.barcodeFormats,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        '${selected.length}/${allFormats.length}',
        style: TextStyle(fontSize: 13, color: st.softTextSecondary),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: () => _showFormatsDialog(context, allFormats, selected),
    );
  }

  void _showFormatsDialog(
    BuildContext context,
    List<String> allFormats,
    List<String> selected,
  ) {
    final l10n = context.l10n;
    var tempSelected = List<String>.from(selected);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(l10n.barcodeFormats),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => tempSelected = List.from(allFormats));
                        },
                        child: Text(l10n.selectAll),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => tempSelected = []);
                        },
                        child: Text(l10n.deselectAll),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: allFormats.map((name) {
                      final isSelected = tempSelected.contains(name);
                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(barcodeFormatLabel(context, name)),
                        dense: true,
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              tempSelected.add(name);
                            } else {
                              tempSelected.remove(name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: tempSelected.isEmpty
                  ? null
                  : () {
                      cubit.updateField(
                        (s) => s.copyWith(barcodeEnabledFormats: tempSelected),
                      );
                      Navigator.of(ctx).pop();
                    },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
