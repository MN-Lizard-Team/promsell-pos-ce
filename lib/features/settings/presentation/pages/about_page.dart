import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/crash_log_service.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/privacy_policy_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/license_page.dart';
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
    await Share.shareXFiles([
      XFile(path),
    ], subject: 'Promsell POS CE — Crash Logs');
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
            child: const Text('OK'),
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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  st.softAccent.withValues(alpha: 0.35),
                  st.softAccent.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(st.cardRadius),
              border: Border.all(
                color: st.softAccent.withValues(alpha: 0.50),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: st.iconContainerBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.point_of_sale,
                    color: st.softAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Promsell POS CE',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.appDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: st.softTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _VersionChip(
                      label: l10n.appVersion,
                      value: version,
                      st: st,
                    ),
                    const SizedBox(width: 12),
                    _VersionChip(
                      label: l10n.appBuild,
                      value: buildNumber,
                      st: st,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.builtWith,
            children: [
              _buildTechRow(
                context,
                Icons.flutter_dash,
                l10n.techStackFlutter,
                st,
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildTechRow(
                context,
                Icons.storage_outlined,
                l10n.techStackDrift,
                st,
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
              _buildLinkTile(
                context,
                Icons.privacy_tip_outlined,
                l10n.privacyPolicy,
                st,
                () => _push(context, const PrivacyPolicyPage()),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildLinkTile(
                context,
                Icons.gavel_outlined,
                l10n.openSourceLicense,
                st,
                () => _push(context, const AppLicensePage()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingsSectionCard(
            title: l10n.crashLogs,
            children: [
              _buildLinkTile(
                context,
                Icons.file_download_outlined,
                l10n.exportCrashLogs,
                st,
                () => _exportCrashLogs(context),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              _buildLinkTile(
                context,
                Icons.delete_outline,
                l10n.clearCrashLogs,
                st,
                () => _clearCrashLogs(context),
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

  Widget _buildTechRow(
    BuildContext context,
    IconData icon,
    String label,
    SettingsThemeExtension st,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: st.iconSize,
            height: st.iconSize,
            decoration: BoxDecoration(
              color: st.iconContainerBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: st.softAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    IconData icon,
    String label,
    SettingsThemeExtension st,
    VoidCallback onTap,
  ) {
    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: st.softAccent, size: 24),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: onTap,
    );
  }
}

class _VersionChip extends StatelessWidget {
  const _VersionChip({
    required this.label,
    required this.value,
    required this.st,
  });

  final String label;
  final String value;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: st.iconContainerBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: st.softAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: st.softTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: st.softAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
