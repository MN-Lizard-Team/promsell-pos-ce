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
    final outline = theme.colorScheme.outlineVariant.withValues(alpha: 0.55);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8, top: 4),
            child: Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
                children: _buildChildrenWithDividers(children, st, outline),
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
