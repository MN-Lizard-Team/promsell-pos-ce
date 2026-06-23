import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/image_settings_labels.dart';

class DemoImagePreview extends StatelessWidget {
  const DemoImagePreview({
    super.key,
    required this.width,
    required this.quality,
    required this.st,
  });

  final int width;
  final int quality;
  final SettingsThemeExtension st;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayWidth = (width / 1600 * 240).clamp(80.0, 240.0);
    final displayHeight = displayWidth * 0.75;
    final roughKb = ((width * width) / 3000 * quality / 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: st.cardBackground,
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: st.cardBorderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: displayWidth,
              height: displayHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    st.softAccent.withValues(alpha: 0.25),
                    st.softAccent.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Image.asset(
                'assets/images/demo/demo_image_01.png',
                width: displayWidth,
                height: displayHeight,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTag(
                icon: Icons.width_normal_outlined,
                label: '$width px',
                st: st,
              ),
              const SizedBox(width: 8),
              _buildTag(
                icon: Icons.high_quality_outlined,
                label: qualityLabel(quality),
                st: st,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '~$roughKb KB · ${l10n.imageExample}',
            style: TextStyle(
              fontSize: 12,
              color: st.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required IconData icon,
    required String label,
    required SettingsThemeExtension st,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: st.iconContainerBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: st.softAccent, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: st.softTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
