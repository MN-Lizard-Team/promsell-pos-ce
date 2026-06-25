import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({this.title, required this.children, super.key});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10, top: 8),
            child: Text(
              title!.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: st.mutedText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                fontSize: 13,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(st.cardRadius),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: _buildChildrenWithDividers(
                  children
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: c,
                        ),
                      )
                      .toList(),
                  st,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildrenWithDividers(
    List<Widget> children,
    SettingsThemeExtension st,
  ) {
    final result = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(
          Divider(
            height: 1,
            indent: st.dividerIndent,
            endIndent: st.dividerIndent,
            color: st.cardBorderColor.withValues(alpha: 0.5),
          ),
        );
      }
    }
    return result;
  }
}
