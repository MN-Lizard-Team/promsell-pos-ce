import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

/// Shared shell for Settings sub-pages: tablet max width + section rhythm.
///
/// Does **not** change save semantics — body content still owns auto-save /
/// explicit save. Matches root Clean Index width (720).
///
/// When [heroIcon] is provided, a slim hero strip (tinted with the page
/// accent) is rendered below the app bar to give every sub-page a consistent
/// visual anchor without per-page boilerplate.
class SettingsLeafChrome extends StatelessWidget {
  const SettingsLeafChrome({
    super.key,
    required this.title,
    required this.children,
    this.header,
    this.actions,
    this.heroIcon,
    this.heroAccent,
    this.bottomNavigationBar,
    this.maxWidth = 720,
  });

  final String title;
  final Widget? header;
  final List<Widget> children;
  final List<Widget>? actions;
  final IconData? heroIcon;
  final Color? heroAccent;
  final Widget? bottomNavigationBar;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);
    final accent = heroAccent ?? theme.colorScheme.primary;
    // Extra bottom room when a sticky bar (e.g. Save) covers the lower edge.
    final bottomPad = bottomNavigationBar != null ? 100.0 : 24 + st.sectionGap;

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      bottomNavigationBar: bottomNavigationBar,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPad),
            children: [
              if (heroIcon != null) _HeroStrip(icon: heroIcon!, accent: accent),
              if (header != null) ...[header!, SizedBox(height: st.sectionGap)],
              ..._withGaps(children, st.sectionGap),
            ],
          ),
        ),
      ),
    );
  }

  static List<Widget> _withGaps(List<Widget> children, double gap) {
    if (children.isEmpty) return const [];
    final out = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      out.add(children[i]);
      if (i != children.length - 1) {
        out.add(SizedBox(height: gap));
      }
    }
    return out;
  }
}

class _HeroStrip extends StatelessWidget {
  const _HeroStrip({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(st.cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
        ],
      ),
    );
  }
}
