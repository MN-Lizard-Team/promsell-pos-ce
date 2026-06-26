import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/crash_log_service.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/license_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/about_header_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/about_link_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/about/about_tech_row.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:share_plus/share_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  Future<void> _exportCrashLogs(BuildContext context) async {
    final l10n = context.l10n;
    final crashLogService = sl<CrashLogService>();
    final path = await crashLogService.exportLogs();
    if (!context.mounted) return;
    if (path == null) {
      AppSnackBar.info(context, l10n.crashLogEmpty);
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: 'Promsell POS CE — Crash Logs',
      ),
    );
  }

  Future<void> _clearCrashLogs(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearCrashLogs),
        content: Text(l10n.clearCrashLogsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await sl<CrashLogService>().clearLogs();
    if (!context.mounted) return;
    AppSnackBar.info(context, l10n.clearCrashLogs);
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    final version = _packageInfo?.version ?? '—';
    final buildNumber = _packageInfo?.buildNumber ?? '—';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutApp)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          AboutHeaderCard(version: version, buildNumber: buildNumber, st: st),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.builtWith,
            children: [
              AboutTechRow(
                icon: Icons.flutter_dash,
                label: l10n.techStackFlutter,
                st: st,
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              AboutTechRow(
                icon: Icons.storage_outlined,
                label: l10n.techStackDrift,
                st: st,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.contactUs,
            children: [
              ListTile(
                leading: Container(
                  width: st.iconSize,
                  height: st.iconSize,
                  decoration: BoxDecoration(
                    color: st.iconContainerBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    color: st.softAccent,
                    size: 24,
                  ),
                ),
                title: Text(
                  'mnlizard.official@gmail.com',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            children: [
              AboutLinkTile(
                icon: Icons.privacy_tip_outlined,
                label: l10n.privacyPolicy,
                st: st,
                onTap: () => _push(context, const PrivacyPolicyPage()),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              AboutLinkTile(
                icon: Icons.gavel_outlined,
                label: l10n.openSourceLicense,
                st: st,
                onTap: () => _push(context, const AppLicensePage()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.crashLogs,
            children: [
              AboutLinkTile(
                icon: Icons.file_download_outlined,
                label: l10n.exportCrashLogs,
                st: st,
                onTap: () => _exportCrashLogs(context),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              AboutLinkTile(
                icon: Icons.delete_outline,
                label: l10n.clearCrashLogs,
                st: st,
                onTap: () => _clearCrashLogs(context),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n.copyrightNotice,
              style: theme.textTheme.bodySmall?.copyWith(color: st.mutedText),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
