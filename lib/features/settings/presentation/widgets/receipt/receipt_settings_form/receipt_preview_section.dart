import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_shared_widgets.dart';

class ReceiptPreviewSection extends StatelessWidget {
  const ReceiptPreviewSection({
    super.key,
    required this.settings,
    required this.onUpdate,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    final s = settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptSharedWidgets.buildSectionTitle(
          context,
          l10n.settingsSectionPreview,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReceiptSharedWidgets.buildChoiceRow(
                context: context,
                icon: Icons.receipt_long_outlined,
                label: l10n.settingsReceiptPreviewStyle,
                options: const ['thermal', 'card', 'none'],
                selected: s.receiptPreviewStyle,
                onSelected: (v) => onUpdate(s.copyWith(receiptPreviewStyle: v)),
                labelBuilder: (v) {
                  if (v == 'thermal') return l10n.receiptPreviewStyleThermal;
                  if (v == 'card') return l10n.receiptPreviewStyleCard;
                  return l10n.receiptPreviewStyleNone;
                },
              ),
              const SizedBox(height: 16),
              ReceiptSharedWidgets.buildSwitchTile(
                context: context,
                icon: Icons.preview_outlined,
                title: l10n.settingsShowPreSalePreview,
                value: s.showPreSalePreview,
                onChanged: (v) => onUpdate(s.copyWith(showPreSalePreview: v)),
              ),
              const SizedBox(height: 8),
              ReceiptSharedWidgets.buildSwitchTile(
                context: context,
                icon: Icons.receipt_outlined,
                title: l10n.settingsShowPostSalePreview,
                value: s.showPostSalePreview,
                onChanged: (v) => onUpdate(s.copyWith(showPostSalePreview: v)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
