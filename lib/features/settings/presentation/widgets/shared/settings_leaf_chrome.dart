import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

/// Shared shell for Settings sub-pages: tablet max width + section rhythm.
///
/// Does **not** change save semantics — body content still owns auto-save /
/// explicit save. Matches root Clean Index width (720).
class SettingsLeafChrome extends StatelessWidget {
  const SettingsLeafChrome({
    super.key,
    required this.title,
    required this.children,
    this.header,
    this.actions,
    this.bottomNavigationBar,
    this.maxWidth = 720,
  });

  final String title;
  final Widget? header;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
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
            padding: EdgeInsets.fromLTRB(0, 12, 0, bottomPad),
            children: [
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
