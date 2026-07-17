import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/promptpay_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/shop_info_settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

enum SettingsAttentionKind { backupOverdue, shopIncomplete, promptpayEmpty }

/// Resolved root attention for Clean Index (priority: backup > shop > PP).
class SettingsAttentionIssue {
  const SettingsAttentionIssue({
    required this.kind,
    required this.title,
    required this.body,
    required this.page,
    required this.icon,
    required this.emphasis,
  });

  final SettingsAttentionKind kind;
  final String title;
  final String body;
  final Widget page;
  final IconData icon;

  /// Error for backup overdue; warning for setup gaps.
  final Color emphasis;

  static List<SettingsAttentionIssue> resolve(
    Settings settings,
    AppLocalizations l10n,
  ) {
    final issues = <SettingsAttentionIssue>[];

    if (settings.backupConfig.isOverdue) {
      issues.add(
        SettingsAttentionIssue(
          kind: SettingsAttentionKind.backupOverdue,
          title: l10n.backupReminderTitle,
          body: l10n.backupReminderMessage(settings.backupReminderDays),
          page: const BackupSettingsPage(),
          icon: Icons.backup_outlined,
          emphasis: AppColors.error,
        ),
      );
    }
    if (!settings.shopInfo.isComplete) {
      issues.add(
        SettingsAttentionIssue(
          kind: SettingsAttentionKind.shopIncomplete,
          title: l10n.settingsAttentionShopTitle,
          body: l10n.settingsAttentionShopBody,
          page: const ShopInfoSettingsPage(),
          icon: Icons.store_outlined,
          emphasis: AppColors.warning,
        ),
      );
    }
    if (settings.promptpayId.isEmpty) {
      issues.add(
        SettingsAttentionIssue(
          kind: SettingsAttentionKind.promptpayEmpty,
          title: l10n.settingsAttentionPromptpayTitle,
          body: l10n.settingsAttentionPromptpayBody,
          page: const PromptpaySettingsPage(),
          icon: Icons.qr_code_2_outlined,
          emphasis: AppColors.warning,
        ),
      );
    }
    return issues;
  }
}

/// Single root attention strip when shop / PromptPay / backup need attention.
class SettingsAttentionBanner extends StatelessWidget {
  const SettingsAttentionBanner({
    super.key,
    required this.settings,
    required this.onOpen,
  });

  final Settings settings;
  final void Function(Widget page) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final issues = SettingsAttentionIssue.resolve(settings, l10n);
    if (issues.isEmpty) return const SizedBox.shrink();

    final st = context.settingsTheme;
    final primary = issues.first;
    final multi = issues.length > 1;

    final title = multi
        ? l10n.settingsAttentionItemsCount(issues.length)
        : primary.title;
    final body = multi
        ? issues.map((i) => _shortLabel(i.kind, l10n)).join(' · ')
        : primary.body;
    final color = primary.emphasis;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(st.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onOpen(primary.page),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: st.tileMinHeight),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Row(
                        children: [
                          Icon(primary.icon, color: color, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  body,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: st.mutedText),
                                ),
                                if (multi) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.settingsAttentionReview,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          color: color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: st.mutedText,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _shortLabel(SettingsAttentionKind kind, AppLocalizations l10n) {
    return switch (kind) {
      SettingsAttentionKind.backupOverdue => l10n.settingsBackup,
      SettingsAttentionKind.shopIncomplete => l10n.settingsShopInfo,
      SettingsAttentionKind.promptpayEmpty => l10n.promptpay,
    };
  }
}
