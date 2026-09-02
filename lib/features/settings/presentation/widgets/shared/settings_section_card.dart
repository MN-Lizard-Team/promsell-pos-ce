import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_header.dart';

/// Grouped card surface for Settings sub-pages. When [accent] is provided,
/// a left accent stripe is rendered and the title becomes a colored pill
/// header ([SettingsSectionHeader]). Otherwise the legacy plain title is
/// used for backward compatibility.
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    this.title,
    this.accent,
    required this.children,
    super.key,
  });

  final String? title;
  final Color? accent;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final outline = st.cardBorderColor.withValues(alpha: 0.72);
    final stripe = accent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          SettingsSectionHeader(title!, accent: accent, showDot: true),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: st.cardBackground,
                  borderRadius: BorderRadius.circular(st.cardRadius),
                  border: Border.all(color: outline, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(st.cardRadius),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      children: _buildChildrenWithDividers(
                        children,
                        st,
                        outline,
                      ),
                    ),
                  ),
                ),
              ),
              if (stripe != null)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: st.accentStripeWidth,
                    decoration: BoxDecoration(
                      color: stripe,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(st.cardRadius),
                        bottomLeft: Radius.circular(st.cardRadius),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(
    List<Widget> children,
    SettingsThemeExtension st,
    Color outline,
  ) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            indent: st.dividerIndent,
            endIndent: 16,
            color: outline,
          ),
        );
      }
    }
    return result;
  }
}
