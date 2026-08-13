import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Shared export affordance for Report and History.
abstract final class ReportExportSheet {
  static Future<String?> show(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PosBottomSheet.show<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                sheetContext.l10n.exportReport,
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Divider(height: 1, color: scheme.outlineVariant),
            ListTile(
              minVerticalPadding: 12,
              leading: Icon(TablerIcons.fileTypePdf, color: scheme.primary),
              title: Text(sheetContext.l10n.exportPdf),
              onTap: () => Navigator.of(sheetContext).pop('pdf'),
            ),
            ListTile(
              minVerticalPadding: 12,
              leading: Icon(TablerIcons.fileTypeCsv, color: scheme.primary),
              title: Text(sheetContext.l10n.exportCsv),
              onTap: () => Navigator.of(sheetContext).pop('csv'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
