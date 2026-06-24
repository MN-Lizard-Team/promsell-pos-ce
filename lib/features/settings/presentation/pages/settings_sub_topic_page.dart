import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/tiles/settings_category_tile.dart';

class SettingsSubTopicPage extends StatefulWidget {
  const SettingsSubTopicPage({
    super.key,
    required this.title,
    required this.subTopics,
  });

  final String title;
  final List<SubTopicItem> subTopics;

  @override
  State<SettingsSubTopicPage> createState() => _SettingsSubTopicPageState();
}

class _SettingsSubTopicPageState extends State<SettingsSubTopicPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Widget _animatedTile(SubTopicItem item, int index) {
    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(index * 0.06, 1.0, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: SettingsCategoryTile(
          icon: item.icon,
          title: item.title,
          subtitle: item.subtitle,
          accentColor: item.accent,
          statusChip: item.statusChip,
          onTap: () => _push(context, item.page),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: widget.subTopics.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          return _animatedTile(widget.subTopics[index], index);
        },
      ),
    );
  }
}

class SubTopicItem {
  const SubTopicItem({
    required this.icon,
    required this.title,
    required this.accent,
    this.subtitle,
    this.statusChip,
    required this.page,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final String? subtitle;
  final Widget? statusChip;
  final Widget page;
}
