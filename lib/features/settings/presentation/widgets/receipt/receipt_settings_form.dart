import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_content_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_preview_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_settings_form/receipt_tax_section.dart';

class ReceiptSettingsForm extends StatelessWidget {
  const ReceiptSettingsForm({
    required this.settings,
    required this.onUpdate,
    super.key,
  });

  final Settings settings;
  final ValueChanged<Settings> onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReceiptContentSection(settings: settings, onUpdate: onUpdate),
        const SizedBox(height: 24),
        ReceiptPreviewSection(settings: settings, onUpdate: onUpdate),
        const SizedBox(height: 24),
        ReceiptTaxSection(settings: settings, onUpdate: onUpdate),
      ],
    );
  }
}
