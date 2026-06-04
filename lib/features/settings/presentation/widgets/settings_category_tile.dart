import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';

class SettingsCategoryTile extends StatefulWidget {
  const SettingsCategoryTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.accentColor,
    this.valuePreview,
    this.statusChip,
    this.hasUnsavedChanges = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? accentColor;
  final Widget? valuePreview;
  final Widget? statusChip;
  final bool hasUnsavedChanges;
  final VoidCallback? onTap;

  @override
  State<SettingsCategoryTile> createState() => _SettingsCategoryTileState();
}

class _SettingsCategoryTileState extends State<SettingsCategoryTile>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.97);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final st = context.settingsTheme;
    final accent = widget.accentColor ?? st.softAccent;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: InkWell(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
        child: Container(
          constraints: BoxConstraints(minHeight: st.tileMinHeight),
          padding: st.tilePadding,
          child: Row(
            children: [
              Container(
                width: st.iconSize,
                height: st.iconSize,
                decoration: BoxDecoration(
                  color: st.iconContainerBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: accent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: st.softTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (widget.valuePreview != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: widget.valuePreview!,
                      ),
                  ],
                ),
              ),
              if (widget.statusChip != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.statusChip!,
                ),
              if (widget.hasUnsavedChanges)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: st.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              Icon(Icons.chevron_right, color: st.softTextSecondary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
